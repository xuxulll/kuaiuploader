//
//  UTAppDelegate.m
//  kuaiuploader
//
//  Created by 徐磊 on 14-5-24.
//  Copyright (c) 2014年 xuxulll. All rights reserved.
//

#import "UTAppDelegate.h"

#import "TFHpple.h"

#import "UTAvFoundationView.h"

@interface UTAppDelegate ()

@property (nonatomic) NSStatusItem *statusItem;

@property (weak) IBOutlet NSImageView *verifyImage;
@property (weak) IBOutlet NSTextField *verifyText;

@property (weak) IBOutlet NSProgressIndicator *verifyIndicator;
@property (weak) IBOutlet NSProgressIndicator *addLinkIndicator;

@property (weak) IBOutlet UTAvFoundationView *playerView;

@end

@implementation UTAppDelegate {
    BOOL _isFolderShare;
    NSMutableArray *_links;
    NSString *_currentLink;
    BOOL _shouldSuspend;
}

+ (void)initialize {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UTFirstLaunch": [NSNumber numberWithBool:YES]}];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _statusItem.menu = _menu;
    _statusItem.highlightMode = YES;
    _statusItem.image = [NSImage imageNamed:@"AppIcon16"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UTFirstLaunch"]) {
        
        [self firstLaunch];
    }
}

- (IBAction)showAddLinkWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    
    [_linkWindow makeKeyAndOrderFront:nil];
}

- (IBAction)addNewLink:(id)sender {
    NSLog(@"new link: %@", _kuaiLink);
    NSString *link = _kuaiLink;
    
    [_addLinkIndicator startAnimation:nil];
    [_addLinkIndicator setHidden:NO];
    
    if ([link rangeOfString:@"kuai"].location == NSNotFound || [link rangeOfString:@"xunlei"].location == NSNotFound) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Please Input A Valid Kuai Link", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
        [alert runModal];
    } else {
        if ([link rangeOfString:@"s"].location != NSNotFound) {
            _isFolderShare = YES;
        } else {
            _isFolderShare = NO;
        }
        
        [self addLinkToThunder:link isFolderShare:_isFolderShare];
        
    }
}

- (IBAction)cancelVerify:(id)sender {
    [NSApp endSheet:_verifyWindow];
    [_verifyWindow close];
    _verifyWindow = nil;
}

- (IBAction)submitVerify:(id)sender {
    
    [_verifyIndicator startAnimation:nil];
    [_verifyIndicator setHidden:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *verify;
        
        NSString *verifyURL = [NSString stringWithFormat:@"http://kuai.xunlei.com/webfilemail_interface?v_code=%@&shortkey=tiMECQIAWgAPkPJQd86&ref=&action=check_verify", [_verifyText.stringValue lowercaseString]];
        
        [self fetchResponseData:[NSURL URLWithString:verifyURL]];
        
        TFHpple *h = [TFHpple hppleWithHTMLData:[self fetchResponseData:[NSURL URLWithString:_currentLink]]];
        
        verify = [self requireVerificationFromTFHpple:h];
        
        if (verify) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _verifyImage.image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:verify]];
                
                [_verifyIndicator stopAnimation:nil];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_verifyIndicator stopAnimation:nil];
                
                [NSApp endSheet:_verifyWindow];
                
                [_verifyWindow close];
                
                _verifyWindow = nil;
                
                _shouldSuspend = NO;
            });
        }
    });
}

- (IBAction)help:(id)sender {
    [self firstLaunch];
}

- (IBAction)about:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [_aboutWindow makeKeyAndOrderFront:nil];
}

- (IBAction)quitApp:(id)sender {
    [NSApp terminate:nil];
}

- (void)firstLaunch {
    [NSApp activateIgnoringOtherApps:YES];
    [_tutorialWindow makeKeyAndOrderFront:nil];
    
    _playerView.videoURL = [NSBundle URLForResource:@"Demo" withExtension:@"mov" subdirectory:nil inBundleWithURL:[[NSBundle mainBundle] bundleURL]];
    
    //NSLog(@"_url: %@", _playerView.videoURL);
    
    [_playerView play];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"UTFirstLaunch"];
}

- (void)addLinkToThunder:(NSString *)xurl isFolderShare:(BOOL)isFolderShare {
    
    _links = [[NSMutableArray alloc] initWithCapacity:0];
    
    _currentLink = xurl;
    
    if (isFolderShare) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *url = xurl;
            
            NSMutableArray *subLinks = [[NSMutableArray alloc] initWithCapacity:0];
            
            TFHpple *h = [TFHpple hppleWithHTMLData:[self fetchResponseData:[NSURL URLWithString:url]]];
            
            NSString *verify = [self requireVerificationFromTFHpple:h];
            
            if (verify) {
                _shouldSuspend = YES;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [NSApp beginSheet:_verifyWindow modalForWindow:_linkWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
                    
                    _verifyImage.image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:verify]];
                });
                
            }
            
            while (_shouldSuspend) {}
            
            h = [TFHpple hppleWithHTMLData:[self fetchResponseData:[NSURL URLWithString:url]]];
            
            NSString *qPage = @"//input[@id='total_task']";
            
            NSArray *pageNodes = [h searchWithXPathQuery:qPage];
            
            NSInteger totalTask = [[pageNodes[0] objectForKey:@"value"] integerValue];
            
            NSInteger total = roundf(totalTask/10) + 1;
            
            for (int i = 0; i < total; i ++) {
                
                if ([url rangeOfString:@"?p_index="].location != NSNotFound) {
                    url = [[url componentsSeparatedByString:@"?"] objectAtIndex:0];
                }
                
                TFHpple *newHpple = [TFHpple hppleWithHTMLData:[self fetchResponseData:[NSURL URLWithString:[url stringByAppendingFormat:@"?p_index=%d", i + 1]]]];
                
                NSString *qStr = @"//div[@class='liebiao']/li/span[@class='c_2']/a";
                
                NSArray *nodes = [newHpple searchWithXPathQuery:qStr];
                
                for (TFHppleElement *element in nodes) {
                    
                    NSString *subUrl = [element objectForKey:@"href"];
                    
                    [subLinks addObject:subUrl];
                }
            }
            
            [self addSublinkToThunder:subLinks];
        });
    } else {
        [self addSublinkToThunder:@[xurl]];
    }
}

- (void)addSublinkToThunder:(NSArray *)links {
    
    NSMutableArray *fileLinks = [[NSMutableArray alloc] initWithCapacity:0];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSString *url in links) {
        
            _currentLink = url;
            
            TFHpple *h = [TFHpple hppleWithHTMLData:[self fetchResponseData:[NSURL URLWithString:url]]];
            
            NSString *verify = [self requireVerificationFromTFHpple:h];
            
            if (verify) {
                
                _shouldSuspend = YES;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [NSApp beginSheet:_verifyWindow modalForWindow:_linkWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
                    
                    _verifyImage.image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:verify]];
                });
            }
            
            while (_shouldSuspend) {}
            
            h = [TFHpple hppleWithHTMLData:[self fetchResponseData:[NSURL URLWithString:url]]];
            
            NSString *qTotalTask = @"//input[@id='file_num']";
            
            NSArray *pageNodes = [h searchWithXPathQuery:qTotalTask];
            
            NSInteger totalTask = [[pageNodes[0] objectForKey:@"value"] integerValue];
            
            NSInteger total = roundf(totalTask/10) + 1;
            
            for (int i = 0; i < total; i ++) {
                
                TFHpple *newHpple = [TFHpple hppleWithHTMLData:[self fetchResponseData:[NSURL URLWithString:[url stringByAppendingFormat:@"?p_index=%d", i + 1]]]];
                
                NSString *qStr = @"//div[@class='file_src file_list liebiao']/ul/li/div/span[@class='c_2']/a";
                
                NSArray *nodes = [newHpple searchWithXPathQuery:qStr];
                
                for (TFHppleElement *element in nodes) {
                    
                    NSString *subUrl = [element objectForKey:@"href"];
                    
                    [fileLinks addObject:subUrl];
                }
            }
        
        }
        
        [self copyToPasteBoard:[fileLinks componentsJoinedByString:@"\r\n"]];
        
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = NSLocalizedString(@"Success", nil);
        notification.informativeText = NSLocalizedString(@"All links has been copied to your pasteboard", nil);
        notification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_addLinkIndicator stopAnimation:nil];
            [_linkWindow close];
            self.kuaiLink = @"";
        });
    });
}


- (NSString *)requireVerificationFromTFHpple:(TFHpple *)hpple {
    NSString *qstr = @"//input[@id='need_verify']";
    NSArray *nodes = [hpple searchWithXPathQuery:qstr];
    if (nodes.count > 0 && [[[nodes objectAtIndex:0] objectForKey:@"value"] boolValue]) {
        NSString *q = @"//form[@class='need_verify_ti']/div/img";
        NSArray *n = [hpple searchWithXPathQuery:q];
        return [[n objectAtIndex:0] objectForKey:@"src"];
    }
    return nil;
}

- (BOOL)copyToPasteBoard:(NSString *)str {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    return [pasteBoard setString:str forType:NSStringPboardType];
}

- (NSData *)fetchResponseData:(NSURL *)url {
    
    NSMutableURLRequest *_urlRequest;
    
    _urlRequest = [[NSMutableURLRequest alloc] init];
    [_urlRequest addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/536.30.1 (KHTML, like Gecko) Version/6.0.5 Safari/536.30.1" forHTTPHeaderField:@"User-Agent"];
    [_urlRequest setTimeoutInterval: 15];
    [_urlRequest addValue:@"kuai.xunlei.com" forHTTPHeaderField:@"Host"];
    [_urlRequest addValue:@"text/xml" forHTTPHeaderField: @"Content-Type"];
    [_urlRequest setURL:url];
    [_urlRequest setHTTPMethod:@"GET"];
    
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableString *cookie_str = [[NSMutableString alloc] init];
    for(NSHTTPCookie *cookie in [cookieJar cookies]){
        if([cookie.domain hasSuffix:@".xunlei.com"]){
            [cookie_str setString:[cookie_str stringByAppendingFormat:@"%@=%@; ", cookie.name, cookie.value]];
        }
    }
    [_urlRequest setValue:cookie_str forHTTPHeaderField:@"Cookie"];
    
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:_urlRequest returningResponse:&urlResponse error:&error];
    
    if (responseData) {
        return responseData;
    }
    return nil;
}


@end

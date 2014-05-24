//
//  UTAppDelegate.m
//  kuaiuploader
//
//  Created by 徐磊 on 14-5-24.
//  Copyright (c) 2014年 xuxulll. All rights reserved.
//

#import "UTAppDelegate.h"

#import "../SSKeyChain/SSKeychain/SSKeychain.h"

@interface UTAppDelegate ()

@property (nonatomic) NSStatusItem *statusItem;

@end

@implementation UTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _statusItem.menu = _menu;
    _statusItem.highlightMode = YES;
    _statusItem.image = [NSImage imageNamed:@"AppIcon16"];
    
}

- (IBAction)showAddLinkWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    
    [_linkWindow makeKeyAndOrderFront:nil];
}

- (IBAction)showPreferencesWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    
    [_prefWindow makeKeyAndOrderFront:nil];
}

- (IBAction)quitApp:(id)sender {
    [NSApp terminate:nil];
}

@end

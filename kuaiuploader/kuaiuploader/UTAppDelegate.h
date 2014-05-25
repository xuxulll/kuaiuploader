//
//  UTAppDelegate.h
//  kuaiuploader
//
//  Created by 徐磊 on 14-5-24.
//  Copyright (c) 2014年 xuxulll. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UTAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *linkWindow;

@property (assign) IBOutlet NSWindow *prefWindow;

@property (assign) IBOutlet NSWindow *verifyWindow;

@property (weak) IBOutlet NSMenu *menu;

@property (copy, nonatomic) NSString *kuaiLink;

@property (assign, nonatomic) BOOL isLoging;

@end

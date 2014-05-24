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

@property (weak) IBOutlet NSMenu *menu;

@end

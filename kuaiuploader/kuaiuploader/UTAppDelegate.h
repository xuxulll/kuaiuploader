//
//  UTAppDelegate.h
//  kuaiuploader
//
//  Created by 徐磊 on 14-5-24.
//  Copyright (c) 2014年 xuxulll. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <AVFoundation/AVFoundation.h>


@interface UTAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *linkWindow;

@property (assign) IBOutlet NSWindow *verifyWindow;

@property (unsafe_unretained) IBOutlet NSWindow *tutorialWindow;

@property (unsafe_unretained) IBOutlet NSWindow *aboutWindow;

@property (weak) IBOutlet NSMenu *menu;

@property (copy, nonatomic) NSString *kuaiLink;

@property (assign, nonatomic) BOOL isLoging;

@end

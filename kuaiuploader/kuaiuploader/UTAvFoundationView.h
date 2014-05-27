//
//  UTAvFoundationView.h
//  kuaiuploader
//
//  Created by 徐磊 on 14-5-27.
//  Copyright (c) 2014年 xuxulll. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <AVFoundation/AVFoundation.h>

@interface UTAvFoundationView : NSView

@property (nonatomic, readonly, strong) AVPlayer* player;
@property (nonatomic, readonly, strong) AVPlayerLayer* playerLayer;
@property (nonatomic, retain) NSURL* videoURL;

- (void) play;


@end

//
//  UTAvFoundationView.m
//  kuaiuploader
//
//  Created by 徐磊 on 14-5-27.
//  Copyright (c) 2014年 xuxulll. All rights reserved.
//

#import "UTAvFoundationView.h"

static void *UTVideoViewPlayerLayerReadyForDisplay = &UTVideoViewPlayerLayerReadyForDisplay;
static void *UTVideoViewPlayerItemStatusContext = &UTVideoViewPlayerItemStatusContext;

@interface UTAvFoundationView ()

- (void)onError:(NSError*)error;
- (void)onReadyToPlay;
- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys;

@end

@implementation UTAvFoundationView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
        _player = [[AVPlayer alloc] init];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:UTVideoViewPlayerItemStatusContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    }
    
    return self;
}

- (void) dealloc {
    [self.player pause];
    [self removeObserver:self forKeyPath:@"player.currentItem.status"];
    [self removeObserver:self forKeyPath:@"playerLayer.readyForDisplay"];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    [_player play];
}

- (void) setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    
    [self.player pause];
    [self.playerLayer removeFromSuperlayer];
    
    AVURLAsset *asset = [AVAsset assetWithURL:self.videoURL];
    NSArray *assetKeysToLoadAndTest = [NSArray arrayWithObjects:@"playable", @"hasProtectedContent", @"tracks", @"duration", nil];
    [asset loadValuesAsynchronouslyForKeys:assetKeysToLoadAndTest completionHandler:^(void) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self setUpPlaybackOfAsset:asset withKeys:assetKeysToLoadAndTest];
        });
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == UTVideoViewPlayerItemStatusContext) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusUnknown:
                break;
            case AVPlayerItemStatusReadyToPlay:
                [self onReadyToPlay];
                break;
            case AVPlayerItemStatusFailed:
                [self onError:nil];
                break;
        }
    } else if (context == UTVideoViewPlayerLayerReadyForDisplay) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue]) {
            self.playerLayer.hidden = NO;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - Private

- (void)onError:(NSError*)error {
    // Notify delegate
}

- (void)onReadyToPlay {
    
}

- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys {
    for (NSString *key in keys) {
        NSError *error = nil;
        if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
            [self onError:error];
            return;
        }
    }
    
    if (!asset.isPlayable || asset.hasProtectedContent) {
        [self onError:nil];
        return;
    }
    
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) { // Asset has video tracks
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.layer.bounds;
        self.playerLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
        self.playerLayer.hidden = YES;
        [self.layer addSublayer:self.playerLayer];
        [self addObserver:self forKeyPath:@"playerLayer.readyForDisplay" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:UTVideoViewPlayerLayerReadyForDisplay];
    }
    
    // Create a new AVPlayerItem and make it our player's current item.
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
}

#pragma mark - Public

- (void) play {
    [self.player play];
}


@end

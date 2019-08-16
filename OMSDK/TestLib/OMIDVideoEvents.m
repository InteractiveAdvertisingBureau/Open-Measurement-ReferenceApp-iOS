//
//  OMIDVideoEvents.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/06/2017.
//

#import <AVFoundation/AVFoundation.h>
#import "OMIDVideoEvents.h"
#import "OMIDAdSession+Private.h"
#import "OMIDVASTProperties+Private.h"
#import "OMIDConstants.h"
#import "OMIDError.h"

#define OUTPUT_VOLUME @"outputVolume"
#define VALID_VOLUME(v) (v >= 0.0 && v <= 1.0)

@interface OMIDVideoEvents () {
    OMIDAdSession *_adSession;
    CGFloat _playerVolume;
    BOOL _observerIsRegistered;
    OMIDMediaEvents *_mediaEvents;
}

@end

@implementation OMIDVideoEvents

- (nullable instancetype)initWithAdSession:(nonnull OMIDAdSession *)session error:(NSError *_Nullable *_Nullable)error {
    self = [super init];
    if (self) {
        _mediaEvents = [[OMIDMediaEvents alloc] initWithAdSession:session error:error];
        
        if (!_mediaEvents) {
            return nil;
        }
    }
    return self;
}

- (void)loadedWithVastProperties:(nonnull OMIDVASTProperties *)vastProperties {
    [_mediaEvents loadedWithVastProperties:vastProperties];
}

- (void)startWithDuration:(CGFloat)duration
        videoPlayerVolume:(CGFloat)videoPlayerVolume {
    [_mediaEvents startWithDuration:duration mediaPlayerVolume:videoPlayerVolume];
}

- (void)firstQuartile {
    [_mediaEvents firstQuartile];
}

- (void)midpoint {
    [_mediaEvents midpoint];
}

- (void)thirdQuartile {
    [_mediaEvents thirdQuartile];
}

- (void)complete {
    [_mediaEvents complete];
}

- (void)pause {
    [_mediaEvents pause];
}

- (void)resume {
    [_mediaEvents resume];
}

- (void)skipped {
    [_mediaEvents skipped];
}

- (void)bufferStart {
    [_mediaEvents bufferStart];
}

- (void)bufferFinish {
    [_mediaEvents bufferFinish];
}

- (void)volumeChangeTo:(CGFloat)playerVolume {
    [_mediaEvents volumeChangeTo:playerVolume];
}

- (void)playerStateChangeTo:(OMIDPlayerState)playerState {
    [_mediaEvents playerStateChangeTo:playerState];
}

- (void)adUserInteractionWithType:(OMIDInteractionType)interactionType {
    [_mediaEvents adUserInteractionWithType:interactionType];
}

@end

//
//  OMIDMediaEvents.m
//  AppVerificationLibrary
//
//  Created by Justin Hines on 6/13/19.
//  Copyright © 2019 Integral Ad Science, Inc. All rights reserved.
//

#import "OMIDMediaEvents.h"
#import <AVFoundation/AVFoundation.h>
#import "OMIDAdSession+Private.h"
#import "OMIDVASTProperties+Private.h"
#import "OMIDError.h"

#define OUTPUT_VOLUME @"outputVolume"
#define VALID_VOLUME(v) (v >= 0.0 && v <= 1.0)

@interface OMIDMediaEvents () {
    OMIDAdSession *_adSession;
    CGFloat _playerVolume;
    BOOL _observerIsRegistered;
}

@end
@implementation OMIDMediaEvents

- (nullable instancetype)initWithAdSession:(nonnull OMIDAdSession *)session error:(NSError *_Nullable *_Nullable)error {
    self = [super init];
    if (self) {
        if (![session.eventFilter acceptEventWithCode:OMIDEventCodeMediaEventsRegistration blockingEventCodes:OMIDEventCodeStart]) {
            [OMIDError setOMIDErrorFor:error code:OMIDEventFilterDoesNotAcceptError message:OMID_EVENT_FILTER_DOES_NOT_ACCEPT_ERROR_MESSAGE];
            return nil;
        }
        if (session.configuration.mediaEventsOwner != OMIDNativeOwner) {
            [OMIDError setOMIDErrorFor:error code:OMIDMediaEventsOwnerShouldBeNativeError message:OMID_MEDIA_OWNER_SHOULD_BE_NATIVE_ERROR_MESSAGE];
            return nil;
        }
        _adSession = session;
        
    }
    return self;
}

- (void)loadedWithVastProperties:(nonnull OMIDVASTProperties *)vastProperties {
    if (vastProperties) {
        [self publishEventWithName:MEDIA_LOADED parameters:[vastProperties toJSON] requireStart:NO];
    }
}

- (void)startWithDuration:(CGFloat)duration
        mediaPlayerVolume:(CGFloat)mediaPlayerVolume {
    if (duration > 0 && VALID_VOLUME(mediaPlayerVolume)) {
        _playerVolume = mediaPlayerVolume;
        [self publishEventWithName:MEDIA_START parameters:@{MEDIA_DURATION: @(duration), MEDIA_PLAYER_VOLUME: @(mediaPlayerVolume), MEDIA_DEVICE_VOLUME: @([self deviceVolume])}];
        [self startListeningForDeviceVolumeChanges];
    }
}

- (void)firstQuartile {
    [self publishEventWithName:MEDIA_FIRST_QUARTILE parameters:nil];
}

- (void)midpoint {
    [self publishEventWithName:MEDIA_MIDPOINT parameters:nil];
}

- (void)thirdQuartile {
    [self publishEventWithName:MEDIA_THIRD_QUARTILE parameters:nil];
}

- (void)complete {
    [self publishEventWithName:MEDIA_COMPLETE parameters:nil];
    [self stopListeningForDeviceVolumeChanges];
}

- (void)pause {
    [self publishEventWithName:MEDIA_PAUSE parameters:nil];
}

- (void)resume {
    [self publishEventWithName:MEDIA_RESUME parameters:nil];
}

- (void)skipped {
    [self publishEventWithName:MEDIA_SKIPPED parameters:nil];
    [self stopListeningForDeviceVolumeChanges];
}

- (void)bufferStart {
    [self publishEventWithName:MEDIA_BUFFER_START parameters:nil];
}

- (void)bufferFinish {
    [self publishEventWithName:MEDIA_BUFFER_FINISH parameters:nil];
}

- (void)volumeChangeTo:(CGFloat)playerVolume {
    if (VALID_VOLUME(playerVolume)) {
        _playerVolume = playerVolume;
        
        // TODO: Remove check after release 1.3.4
        if (_adSession.configuration.creativeType) {
            [self publishEventWithName:MEDIA_VOLUME_CHANGE parameters:@{MEDIA_PLAYER_VOLUME: @(playerVolume), MEDIA_DEVICE_VOLUME: @([self deviceVolume])}];
        } else {
            [self publishEventWithName:MEDIA_VOLUME_CHANGE parameters:@{VIDEO_PLAYER_VOLUME: @(playerVolume), MEDIA_DEVICE_VOLUME: @([self deviceVolume])}];
        }
    }
}

- (void)playerStateChangeTo:(OMIDPlayerState)playerState {
    NSString *temp = [self stringFromPlayerState:playerState];
    if (temp) {
        [self publishEventWithName:MEDIA_PLAYER_STATE_CHANGE parameters:@{MEDIA_PLAYER_STATE: temp}];
    }
}

- (void)adUserInteractionWithType:(OMIDInteractionType)interactionType {
    NSString *temp = [self stringFromInteractionType:interactionType];
    if (temp) {
        [self publishEventWithName:MEDIA_USER_INTERACTION parameters:@{MEDIA_INTERACTION_TYPE: temp}];
    }
}

- (void)publishEventWithName:(NSString *)name parameters:(NSDictionary *)parameters {
    [self publishEventWithName:name parameters:parameters requireStart:YES];
}

- (void)publishEventWithName:(NSString *)name parameters:(NSDictionary *)parameters requireStart:(BOOL)requireStart {
    OMIDEventCode requiredEvents = (requireStart) ? (OMIDEventCodeStart) : 0;
    if ([_adSession.eventFilter acceptAnyEventWithRequiredEventCodes:requiredEvents]) {
        [_adSession.mediaEventsPublisher publishMediaEventWithName:name parameters:parameters];
    }
}

- (NSString *)stringFromPlayerState:(OMIDPlayerState)playerState {
    switch (playerState) {
        case OMIDPlayerStateMinimized:
            return MEDIA_PLAYER_STATE_MINIMIZED;
            
        case OMIDPlayerStateCollapsed:
            return MEDIA_PLAYER_STATE_COLLAPSED;
            
        case OMIDPlayerStateNormal:
            return MEDIA_PLAYER_STATE_NORMAL;
            
        case OMIDPlayerStateExpanded:
            return MEDIA_PLAYER_STATE_EXPANDED;
            
        case OMIDPlayerStateFullscreen:
            return MEDIA_PLAYER_STATE_FULLSCREEN;
    }
    return nil;
}

- (NSString *)stringFromInteractionType:(OMIDInteractionType)interactionType {
    switch (interactionType) {
        case OMIDInteractionTypeClick:
            return MEDIA_USER_INTERACTION_CLICK;
            
        case OMIDInteractionTypeAcceptInvitation:
            return MEDIA_USER_INTERACTION_ACCEPT_INVITATION;
    }
    return nil;
}

- (CGFloat)deviceVolume {
    return [AVAudioSession sharedInstance].outputVolume;
}

- (void)startListeningForDeviceVolumeChanges {
    if (!_observerIsRegistered) {
        [[AVAudioSession sharedInstance] addObserver:self forKeyPath:OUTPUT_VOLUME options:0 context:nil];
        _observerIsRegistered = YES;
    }
}

- (void)stopListeningForDeviceVolumeChanges {
    if (_observerIsRegistered) {
        [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:OUTPUT_VOLUME];
        _observerIsRegistered = NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self volumeChangeTo:_playerVolume];
}

- (void)dealloc {
    [self stopListeningForDeviceVolumeChanges];
}
@end

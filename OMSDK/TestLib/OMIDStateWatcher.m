//
//  OMIDStateWatcher.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 23/07/15.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "OMIDStateWatcher.h"
#import "OMIDAdSessionRegistry.h"
#import "OMIDAdSession+Private.h"
#import "OMIDConstants.h"

#define OUTPUT_VOLUME @"outputVolume"

@implementation OMIDStateWatcher

+ (OMIDStateWatcher *)getInstance {
    static dispatch_once_t pred = 0;
    __strong static OMIDStateWatcher *omidStateWatcher;
    dispatch_once(&pred, ^{
        omidStateWatcher = [[self alloc] init];
    });
    return omidStateWatcher;
}

- (BOOL)appIsActive {
    return _appState == OMIDAppStateForegrounded;
}

- (void)start {
    _appState = [self appStateFromUIApplicationState:UIApplication.sharedApplication.applicationState];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[AVAudioSession sharedInstance] addObserver:self forKeyPath:OUTPUT_VOLUME options:0 context:nil];
}

- (void)stop {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:OUTPUT_VOLUME];
}

- (void)adSessionDidBecomeActive:(OMIDAdSession *)adSession {
    [adSession.statePublisher publishAppState:[self appStateString]];
}

- (void)updateAppStateWithUIApplicationState:(UIApplicationState)state {
    OMIDAppState appState = [self appStateFromUIApplicationState:state];
    if (appState == _appState) {
        return;
    }
    _appState = appState;
    NSString *appStateString = [self appStateString];
    for (OMIDAdSession *adSession in [OMIDAdSessionRegistry getInstance].activeAdSessions) {
        [adSession.statePublisher publishAppState:appStateString];
    }
    if (self.appIsActive) {
        [self.delegate appDidBecomeActive];
    } else {
        [self.delegate appDidResignActive];
    }
}

- (NSString *)appStateString {
    switch (_appState) {
        case OMIDAppStateForegrounded:
            return APP_STATE_FOREGROUNDED;
            
        case OMIDAppStateBackgrounded:
            return APP_STATE_BACKGROUNDED;
    }
}

- (OMIDAppState)appStateFromUIApplicationState:(UIApplicationState)state {
    switch (state) {
        case UIApplicationStateActive:
            return OMIDAppStateForegrounded;
            
        case UIApplicationStateInactive:
            return OMIDAppStateBackgrounded;
            
        case UIApplicationStateBackground:
            return OMIDAppStateBackgrounded;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:OUTPUT_VOLUME])
    {
        for (OMIDAdSession *adSession in [OMIDAdSessionRegistry getInstance].activeAdSessions) {
            [adSession.statePublisher publishDeviceVolume:[self deviceVolume]];
        }
    }
}

- (CGFloat)deviceVolume {
    return [AVAudioSession sharedInstance].outputVolume;
}

#pragma mark Notifications

- (void)onAppDidBecomeActive {
    [self updateAppStateWithUIApplicationState:UIApplicationStateActive];
}

- (void)onAppWillResignActive {
    [self updateAppStateWithUIApplicationState:UIApplicationStateInactive];
}

- (void)onAppDidEnterBackground {
    [self updateAppStateWithUIApplicationState:UIApplicationStateBackground];
}

@end

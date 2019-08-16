//
//  OMIDAdViewRegistry.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 28/08/15.
//

#import <Foundation/Foundation.h>
#import "OMIDAdSessionRegistry.h"
#import "OMIDAdSession+Private.h"

@interface OMIDAdSessionRegistry () {
    NSPointerArray *_adSessions;
    NSMutableArray *_activeAdSessions;
    NSMutableArray *_observers;
}

@end

@implementation OMIDAdSessionRegistry

+ (OMIDAdSessionRegistry *)getInstance {
    static dispatch_once_t pred = 0;
    __strong static OMIDAdSessionRegistry *instance;
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _adSessions = [NSPointerArray weakObjectsPointerArray];
        _activeAdSessions = [NSMutableArray new];
        _observers = [NSMutableArray new];
    }
    return self;
}

- (NSArray *)adSessions {
    [_adSessions compact];
    return [_adSessions allObjects];
}

- (NSArray *)activeAdSessions {
    return _activeAdSessions;
}

- (NSArray<id<OMIDAdSessionRegistryStateObserver>> *)observers {
    return _observers;
}

- (BOOL)isActive {
    return _activeAdSessions.count > 0;
}

- (void)addAdSession:(OMIDAdSession *)adSession {
    [_adSessions addPointer:(__bridge void *)adSession];
    adSession.delegate = self;
}

- (void)removeAdSession:(OMIDAdSession *)adSession {
    [_activeAdSessions removeObject:adSession];
    for (NSUInteger i = 0; i < _adSessions.count; i++) {
        id pointer = [_adSessions pointerAtIndex:i];
        if (pointer == adSession) {
            [_adSessions removePointerAtIndex:i];
            break;
        }
    }
}

- (void)addStateObserver:(id<OMIDAdSessionRegistryStateObserver>)observer {
    [_observers addObject:observer];
}

#pragma mark AdSessionDelegate

- (void)adSessionDidStart:(OMIDAdSession *)adSession {
    BOOL wasActive = self.isActive;
    [_activeAdSessions addObject:adSession];
    if (!wasActive) {
        for (id<OMIDAdSessionRegistryStateObserver> observer in _observers) {
            [observer adSessionRegistryDidBecomeActive];
        }
    }
    for (id<OMIDAdSessionRegistryStateObserver> observer in _observers) {
        [observer adSessionDidBecomeActive:adSession];
    }
}

- (void)adSessionDidFinish:(OMIDAdSession *)adSession {
    BOOL wasActive = self.isActive;
    [self removeAdSession:adSession];
    if (wasActive && !self.isActive) {
        for (id<OMIDAdSessionRegistryStateObserver> observer in _observers) {
            [observer adSessionRegistryDidResignActive];
        }
    }
}

- (void)adSession:(OMIDAdSession *)adSession didRegisterAdView:(UIView *)adView {
    for (OMIDAdSession *session in self.adSessions) {
        if (session != adSession && session.mainAdView == adView) {
            session.mainAdView = nil;
            break;
        }
    }
}

@end

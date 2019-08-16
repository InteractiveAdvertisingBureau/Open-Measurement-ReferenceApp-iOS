//
//  OMIDManager.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 23/07/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OMIDManager.h"
#import "OMIDTreeWalker.h"

@implementation OMIDManager

+ (OMIDManager *)getInstance {
    static dispatch_once_t pred = 0;
    __strong static OMIDManager *omidManagerInstance;
    dispatch_once(&pred, ^{
        omidManagerInstance = [[self alloc] init];
    });
    return omidManagerInstance;
}

- (void)setup {
    [[OMIDAdSessionRegistry getInstance] addStateObserver:self];
}

- (void)start {
    [OMIDStateWatcher getInstance].delegate = self;
    [[OMIDStateWatcher getInstance] start];
    if ([OMIDStateWatcher getInstance].appIsActive) {
        [[OMIDTreeWalker getInstance] start];
    }
}

- (void)stop {
    [OMIDStateWatcher getInstance].delegate = nil;
    [[OMIDStateWatcher getInstance] stop];
    [[OMIDTreeWalker getInstance] stop];
}

#pragma mark OMIDStateWatcherDelegate

- (void)appDidBecomeActive {
    [[OMIDTreeWalker getInstance] start];
}

- (void)appDidResignActive {
    [[OMIDTreeWalker getInstance] pause];
}

#pragma mark OMIDAdSessionRegistryStateObserver

- (void)adSessionRegistryDidBecomeActive {
    [self start];
}

- (void)adSessionRegistryDidResignActive {
    [self stop];
}

- (void)adSessionDidBecomeActive:(OMIDAdSession *)adSession {
    [[OMIDStateWatcher getInstance] adSessionDidBecomeActive:adSession];
}

@end

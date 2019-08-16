//
//  OMIDAdSessionStatePublisher.m
//  AppVerificationLibrary
//
//  Created by Daria on 06/07/2017.
//

#import "OMIDAdSessionStatePublisher.h"
#import "OMIDCommand.h"
#import "OMIDConstants.h"

@implementation OMIDAdSessionStatePublisher

- (instancetype)initWithCommandPublisher:(id<OMIDCommandPublisher>)commandPublisher {
    self = [super init];
    if (self) {
        _commandPublisher = commandPublisher;
        _timestamp = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (void)cleanupAdState {
    _timestamp = [[NSDate date] timeIntervalSince1970];
    _adState = OMIDAdStateIdle;
}

- (void)publishNativeViewStateWithHierarchy:(NSString *)hierarchy
                                  timestamp:(NSTimeInterval)timestamp {
    if (timestamp > _timestamp) {
        _adState = OMIDAdStateVisible;
        NSString *command;
        if (hierarchy != nil) {
            command = [OMIDCommand commandWithName:SET_NATIVE_VIEW_HIERARCHY, hierarchy, nil];
        } else {
            NSString *errorMessage = @"Bad view hierarchy data for OMID geometry event";
            command = [OMIDCommand errorCommandWithType:OMIDErrorGeneric errorMessage:errorMessage];
        }
        [_commandPublisher publishCommand:command];
    }
}

- (void)publishEmptyNativeViewStateWithHierarchy:(NSString *)hierarchy
                                       timestamp:(NSTimeInterval)timestamp {
    if (timestamp > _timestamp && _adState != OMIDAdStateHidden) {
        _adState = OMIDAdStateHidden;
        NSString *command;
        if (hierarchy != nil) {
            command = [OMIDCommand commandWithName:SET_NATIVE_VIEW_HIERARCHY, hierarchy, nil];
        } else {
            NSString *errorMessage = @"Bad hidden view data for OMID geometry event";
            command = [OMIDCommand errorCommandWithType:OMIDErrorGeneric errorMessage:errorMessage];
        }
        [_commandPublisher publishCommand:command];
    }
}

- (void)publishAppState:(NSString *)appState {
    NSString *strAppState = [OMIDCommand stringWithQuotesFromString:appState];
    NSString *command = [OMIDCommand commandWithName:SET_APP_STATE, strAppState, nil];
    [_commandPublisher publishCommand:command];
}

- (void)publishDeviceVolume:(CGFloat)volume {
    NSString *strVolume = [NSString stringWithFormat:@"%.2f", volume];
    NSString *command = [OMIDCommand commandWithName:SET_DEVICE_VOLUME, strVolume, nil];
    [_commandPublisher publishCommand:command];
}
@end

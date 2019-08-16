//
//  OMIDEventFilter.m
//  AppVerificationLibrary
//
//  Created by Daria on 06/07/2017.
//

#import "OMIDEventFilter.h"

@interface OMIDEventFilter () {
    NSUInteger _codes;
    OMIDEventCode _finalEventCode;
    dispatch_queue_t _syncQueue;
}

@end

@implementation OMIDEventFilter

- (instancetype)initWithFinalEventCode:(OMIDEventCode)eventCode {
    self = [super init];
    if (self) {
        _finalEventCode = eventCode;
        _syncQueue = dispatch_queue_create("com.iab.omidEventFilter.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (BOOL)isFinalEventAccepted {
    __block BOOL result = NO;
    dispatch_sync(_syncQueue, ^{
        result = (_codes & _finalEventCode) != 0;
    });
    return result;
}

- (BOOL)acceptEventWithCode:(OMIDEventCode)eventCode {
    return [self acceptEventWithCode:eventCode blockingEventCodes:0];
}

- (BOOL)acceptEventWithCode:(OMIDEventCode)eventCode blockingEventCodes:(OMIDEventCode)blockingEventCodes {
    __block BOOL result = NO;
    dispatch_barrier_sync(_syncQueue, ^{
        if ((_codes & (_finalEventCode | blockingEventCodes | eventCode)) != 0) {
            result = NO;
        } else {
            _codes = _codes | eventCode;
            result = YES;
        }
    });
    return result;
}

- (BOOL)acceptAnyEventWithRequiredEventCodes:(OMIDEventCode)requiredEventCodes {
    __block BOOL result = NO;
    dispatch_sync(_syncQueue, ^{
        result = (_codes & _finalEventCode) == 0 && (_codes & requiredEventCodes) == requiredEventCodes;
    });
    return result;
}

@end

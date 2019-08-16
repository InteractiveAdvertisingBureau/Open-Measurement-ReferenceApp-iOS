//
//  OMIDJSTimer.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 09/03/17.
//

#import "OMIDJSTimer.h"

#define SET_TIMEOUT @"setTimeout"
#define CLEAR_TIMEOUT @"clearTimeout"
#define SET_INTERVAL @"setInterval"
#define CLEAR_INTREVAL @"clearInterval"

@interface OMIDJSTimer ()

@property(nonatomic, readonly) NSUInteger timerIdCounter;

@end

@implementation OMIDJSTimer

- (id)init {
    self = [super init];
    if (self) {
        _timerIds = [NSMutableSet new];
    }
    return self;
}

- (void)setupMethodsForJSObject:(JSValue *)jsObject {
    __weak typeof(self) weakSelf = self;
    jsObject[SET_TIMEOUT] = ^(JSValue *callback, JSValue *timeout) {
        typeof(weakSelf) strongSelf = weakSelf;
        return [strongSelf scheduleTimerWithTimeout:timeout callback:callback repeatable:NO];
    };
    jsObject[CLEAR_TIMEOUT] = ^(JSValue *timerId) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf cancelTimerWithId:timerId];
    };
    jsObject[SET_INTERVAL] = ^(JSValue *callback, JSValue *timeout) {
        typeof(weakSelf) strongSelf = weakSelf;
        return [strongSelf scheduleTimerWithTimeout:timeout callback:callback repeatable:YES];
    };
    jsObject[CLEAR_INTREVAL] = ^(JSValue *timerId) {
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf cancelTimerWithId:timerId];
    };
}

- (NSNumber *)scheduleTimerWithTimeout:(JSValue *)timeout callback:(JSValue *)callback repeatable:(BOOL)repeatable {
    _timerIdCounter++;
    NSNumber *timerId = @(_timerIdCounter);
    [_timerIds addObject:timerId];
    double timeoutMillis = [timeout toDouble];
    if (timeoutMillis < 10) {
        timeoutMillis = 10;
    }
    [self scheduleTimerWithId:timerId timeout:timeoutMillis callback:callback repeatable:repeatable];
    return timerId;
}

- (void)scheduleTimerWithId:(NSNumber *)timerId timeout:(double)timeout callback:(JSValue *)callback repeatable:(BOOL)repeatable {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeout * NSEC_PER_MSEC), self.jsInvoker.dispatchQueue, ^{
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf handleTimerWithId:timerId timeout:timeout callback:callback repeatable:repeatable];
    });
}

- (void)handleTimerWithId:(NSNumber *)timerId timeout:(double)timeout callback:(JSValue *)callback repeatable:(BOOL)repeatable {
    if (![_timerIds containsObject:timerId]) {
        return;   
    }
    if (repeatable) {
        [self scheduleTimerWithId:timerId timeout:timeout callback:callback repeatable:YES];
    } else {
        [_timerIds removeObject:timerId];
    }
    [self.jsInvoker invokeCallback:callback];
}

- (void)cancelTimerWithId:(JSValue *)timerId {
    [_timerIds removeObject:[timerId toNumber]];
}

- (void)cancelAllTimers {
    [_timerIds removeAllObjects];
}

@end

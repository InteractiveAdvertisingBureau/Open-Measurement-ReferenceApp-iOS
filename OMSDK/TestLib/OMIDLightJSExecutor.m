//
//  OMIDLightJSExecutor.m
//  AppVerificationLibrary
//
//  Created by Daria on 06/03/17.
//

#import "OMIDJSTimer.h"
#import "OMIDJSNetworkBridge.h"
#import "OMIDLightJSExecutor.h"

#define OMID_NATIVE @"omidNative"
#define INITIALIZATION_SCRIPT @"this.omidNative = {};"

@implementation OMIDLightJSExecutor

+ (OMIDLightJSExecutor *)lightJSExecutor {
    OMIDJSTimer *timer = [OMIDJSTimer new];
    OMIDJSNetworkBridge *networkBridge = [OMIDJSNetworkBridge new];
    return [[self alloc] initWithTimer:timer networkBridge:networkBridge];
}

- (id)initWithTimer:(OMIDJSTimer *)timer networkBridge:(OMIDJSNetworkBridge *)networkBridge {
    self = [super init];
    if (self) {
        _dispatchQueue = dispatch_queue_create("com.iab.omidLightJSExecutor.serial.queue", DISPATCH_QUEUE_SERIAL);
        _timer = timer;
        _timer.jsInvoker = self;
        _networkBridge = networkBridge;
        _networkBridge.jsInvoker = self;
        dispatch_async(_dispatchQueue, ^{
            _jsContext = [JSContext new];
            [_jsContext evaluateScript:INITIALIZATION_SCRIPT];
            JSValue *OMIDNative = _jsContext[OMID_NATIVE];
            [_timer setupMethodsForJSObject:OMIDNative];
            [_networkBridge setupMethodsForJSObject:OMIDNative];
        });
    }
    return self;
}

- (BOOL)supportBackgroundThread {
    return YES;
}

- (id)jsEnvironment {
    return _jsContext;
}

- (void)injectJavaScriptFromString:(NSString *)javascript {
    dispatch_async(_dispatchQueue, ^{
        [self invokeScript:javascript];
    });
}

- (void)invokeCallback:(JSValue *)callback {
    if (callback.isString) {
        [self invokeScript:[callback toString]];
    } else if (!callback.isUndefined && !callback.isNull) {
        [callback callWithArguments:nil];
    }
}

- (void)invokeCallback:(JSValue *)callback argument:(nonnull id)argument {
    [callback callWithArguments:@[argument]];
}

- (void)invokeScript:(NSString *)script {
    if (![script isEqual:@""]) {
        [_jsContext evaluateScript:script];
    }
}

@end

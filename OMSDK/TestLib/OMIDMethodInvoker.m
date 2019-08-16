//
//  OMIDMethodInvoker.m
//  AppVerificationLibrary
//
//  Created by Daria on 10/07/2017.
//

#import "OMIDMethodInvoker.h"

@implementation OMIDMethodInvoker

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
+ (void)performSelectorAsync:(SEL)selector target:(id)target {
    if (NSThread.isMainThread) {
        [target performSelector:selector];
    } else {
        __weak typeof(target) weakTarget = target;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakTarget performSelector:selector];
        });
    }
}

+ (void)performSelectorAsync:(SEL)selector target:(id)target argument:(id)argument {
    if (NSThread.isMainThread) {
        [target performSelector:selector withObject:argument];
    } else {
        __weak typeof(target) weakTarget = target;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakTarget performSelector:selector withObject:argument];
        });
    }
}

+ (void)performSelectorSync:(SEL)selector target:(id)target argument:(id)argument {
    if (NSThread.isMainThread) {
        [target performSelector:selector withObject:argument];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [target performSelector:selector withObject:argument];
        });
    }
}

#pragma clang diagnostic pop

@end

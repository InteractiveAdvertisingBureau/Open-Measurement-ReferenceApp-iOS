//
//  OMIDScreenProcessor.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/10/15.
//
#import <UIKit/UIKit.h>
#import "OMIDDictionaryUtil.h"
#import "OMIDScreenProcessor.h"

@implementation OMIDScreenProcessor

- (NSMutableDictionary *)stateForView:(UIView *)view {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if ((NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        screenBounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
    }
    return [OMIDDictionaryUtil stateWithFrame:screenBounds clipsToBounds:YES];
}

- (NSArray *)childrenForView:(UIView *)view {
    NSMutableArray *array = [NSMutableArray array];
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (window.screen == [UIScreen mainScreen] && ![self isInternalWindow:window]) {
            [array addObject:window];
        }
    }
    return array;
}

- (NSArray *)orderedChildrenForView:(UIView *)view {
    return [self childrenForView:view];
}

- (BOOL)isInternalWindow:(UIWindow *)window {
    NSString *windowClassName = NSStringFromClass([window class]);
    NSArray *internalWindowClassNames = @[@"UITextEffectsWindow", @"UIRemoteKeyboardWindow"];
    return [internalWindowClassNames containsObject: windowClassName];
}

@end

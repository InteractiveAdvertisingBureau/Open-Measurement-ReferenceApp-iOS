//
//  OMIDWindowProcessor.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/10/15.
//
#import <UIKit/UIKit.h>
#import "OMIDWindowProcessor.h"

@implementation OMIDWindowProcessor

- (CGRect)frameInWindowSystemForView:(UIView *)view {
    return view.bounds;
}

- (UIWindow *)windowForView:(UIView *)view {
    return (UIWindow *)view;
}

@end

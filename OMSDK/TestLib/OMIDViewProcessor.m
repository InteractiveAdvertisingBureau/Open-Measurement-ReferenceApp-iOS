//
//  OMIDViewProcessor.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/10/15.
//
#import <UIKit/UIKit.h>
#import "OMIDViewProcessor.h"
#import "OMIDDictionaryUtil.h"

#define DEFAULT_Z_POSITION 0


@implementation OMIDViewProcessor

- (NSMutableDictionary *)stateForView:(UIView *)view {
    CGRect frame = [self frameInWindowSystemForView:view];
    frame = [[self windowForView:view] convertRect:frame toWindow:nil];
    return [OMIDDictionaryUtil stateWithFrame:frame clipsToBounds:view.clipsToBounds];
}

- (NSArray *)childrenForView:(UIView *)view {
    return view.subviews;
}

- (NSArray *)orderedChildrenForView:(UIView *)view {
    NSMutableDictionary *dictionary = nil;
    NSUInteger count = 0;
    NSArray *subviews = view.subviews;
    for (UIView *subview in subviews) {
        CGFloat zPosition = subview.layer.zPosition;
        if (dictionary) {
            [self addView:subview toDictionary:dictionary];
        } else if (zPosition == DEFAULT_Z_POSITION) {
            count++;
        } else {
            dictionary = [NSMutableDictionary new];
            NSMutableArray *array = [NSMutableArray arrayWithArray:[subviews subarrayWithRange:NSMakeRange(0, count)]];
            [dictionary setObject:array forKey:@(DEFAULT_Z_POSITION)];
            [self addView:subview toDictionary:dictionary];
        }
    }
    return (dictionary) ? [self buildChildrenFromDictionary:dictionary] : subviews;
}

- (CGRect)frameInWindowSystemForView:(UIView *)view {
    return [view convertRect:view.bounds toView:nil];
}

- (UIWindow *)windowForView:(UIView *)view {
    return view.window;
}

- (void)addView:(UIView *)view toDictionary:(NSMutableDictionary *)dictionary {
    NSNumber *zPosition = @(view.layer.zPosition);
    NSMutableArray *array = [dictionary objectForKey:zPosition];
    if (!array) {
        array = [NSMutableArray new];
        [dictionary setObject:array forKey:zPosition];
    }
    [array addObject:view];
}

- (NSArray *)buildChildrenFromDictionary:(NSMutableDictionary *)dictionary {
    NSArray *keys = [[dictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult (NSNumber *obj1, NSNumber *obj2) {
        return [obj1 compare:obj2];
    }];
    NSMutableArray *result = [NSMutableArray new];
    for (NSNumber *key in keys) {
        [result addObjectsFromArray:[dictionary objectForKey:key]];
    }
    return result;
}

@end

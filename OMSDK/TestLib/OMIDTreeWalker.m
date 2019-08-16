//
//  OMIDTreeWalker.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 24/07/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OMIDTreeWalker.h"
#import "OMIDDictionaryUtil.h"
#import "OMIDAdSessionRegistry.h"
#import "OMIDProcessorFactory.h"
#import "OMIDNodeProcessor.h"
#import "OMIDAdViewCache.h"
#import "OMIDStatePublisher.h"

#define TIMER_PERIOD 0.2

@interface OMIDTreeWalker () {
    NSTimer *_timer;
    NSUInteger _count;
    NSDate *_date1;
    NSDate *_date2;
}

@property(nonatomic, readonly) OMIDProcessorFactory *processorFactory;;
@property(nonatomic, readonly) OMIDAdViewCache *adViewCache;
@property(nonatomic, readonly) OMIDStatePublisher *statePublisher;

@end


@implementation OMIDTreeWalker

+ (OMIDTreeWalker *)getInstance {
    static dispatch_once_t pred = 0;
    __strong static OMIDTreeWalker *omidTreeWalker;
    dispatch_once(&pred, ^{
        omidTreeWalker = [[self alloc] init];
    });
    return omidTreeWalker;
}

- (id)init {
    self = [super init];
    if (self) {
        _processorFactory = [OMIDProcessorFactory new];
        _adViewCache = [[OMIDAdViewCache alloc] initWithAdSessionRegistry:[OMIDAdSessionRegistry getInstance]];
        _statePublisher = [[OMIDStatePublisher alloc] initWithAdSessionRegistry:[OMIDAdSessionRegistry getInstance]];
    }
    return self;
}

- (void)start {
    [self updateTreeState];
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:TIMER_PERIOD
                                         target:self
                                       selector:@selector(onTick:)
                                       userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stop {
    [self pause];
    [_statePublisher cleanupCache];
}

- (void)pause {
    [_timer invalidate];
    _timer = nil;
    [self.timeLogger didProcessObjectsCount:0 withTime:0];
}

- (void)updateTreeState {
    [self beforeWalk];
    [self doWalk];
    [self afterWalk];
}

- (void)beforeWalk {
    _count = 0;
    _date1 = [NSDate date];
}

- (void)afterWalk {
    _date2 = [NSDate date];
    [self.timeLogger didProcessObjectsCount:_count withTime:[_date2 timeIntervalSinceDate:_date1] * 1000];
}

- (void)doWalk {
    [_adViewCache prepare];
    id<OMIDNodeProcessor> processor = [_processorFactory rootProcessor];
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    if (_adViewCache.hiddenSessionIds.count > 0) {
        [_statePublisher publishEmptyStateToSessions:_adViewCache.hiddenSessionIds timestamp:timestamp];
    }
    if (_adViewCache.visibleSessionIds.count > 0) {
        NSMutableDictionary *state = [processor stateForView:nil];
        [self walkChildrenForView:nil processor:processor state:state type:OMIDViewTypeRoot];
        [_statePublisher publishState:state toSessions:_adViewCache.visibleSessionIds timestamp:timestamp];
    } else {
        [_statePublisher cleanupCache];
    }
    [_adViewCache cleanup];
}

- (void)walkView:(UIView *)view processor:(id<OMIDNodeProcessor>)processor parentState:(NSMutableDictionary *)parentState {
    if (view.hidden || view.alpha == 0) {
        return;
    }
    OMIDViewType type = [_adViewCache typeForView:view];
    if (type == OMIDViewTypeUnderlying) {
        return;
    }
    _count++;
    NSMutableDictionary *state = [processor stateForView:view];
    [OMIDDictionaryUtil state:parentState addChildState:state];
    BOOL isAdPlacement = [self handleAdView:view withState:state];
    if (!isAdPlacement) {
        [self checkFriendlyObstruction:view withState:state];
        [self walkChildrenForView:view processor:processor state:state type:type];
    }
}

- (void)walkChildrenForView:(UIView *)view processor:(id<OMIDNodeProcessor>)processor state:(NSMutableDictionary *)state type:(OMIDViewType)type {
    NSArray *children = (type == OMIDViewTypeRoot) ? [processor orderedChildrenForView:view] : [processor childrenForView:view];
    id<OMIDNodeProcessor> processorForChildren = processor.processorForChildren;
    for (UIView *child in children) {
        [self walkView:child processor:processorForChildren parentState:state];
    }
}

- (BOOL)handleAdView:(UIView *)view withState:(NSMutableDictionary *)state {
    NSString *sessionId = [_adViewCache sessionIdForView:view];
    if (!sessionId) {
        return NO;
    }
    [OMIDDictionaryUtil state:state addSessionId:sessionId];
    [_adViewCache onAdViewProcessed];
    return YES;
}

- (void)checkFriendlyObstruction:(UIView *)view withState:(NSMutableDictionary *)state {
    OMIDObstructionInfo *obstructionInfo = [_adViewCache obstructionInfoForView:view];
    if (obstructionInfo) {
        [OMIDDictionaryUtil state:state addObstructionInfo:obstructionInfo];
    }
}

- (void)onTick:(NSTimer *)timer {
    [self updateTreeState];
}

@end

//
//  OMIDAdViewCache.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 02/02/17.
//

#import "OMIDAdSessionRegistry.h"
#import "OMIDViewKey.h"
#import "OMIDAdSession+Private.h"
#import "OMIDAdViewCache.h"

@interface OMIDAdViewCache () {
    NSMutableDictionary<OMIDViewKey *, NSString *> *_adViews;
    NSMutableDictionary<OMIDViewKey *, OMIDObstructionInfo *> *_friendlyObstructionInfo;
    BOOL _isAdViewProcessed;
    NSMutableSet *_rootViews;
    NSMutableSet *_visibleSessionIds;
    NSMutableSet *_hiddenSessionIds;
}

@end

@implementation OMIDAdViewCache

- (id)initWithAdSessionRegistry:(OMIDAdSessionRegistry *)adSessionRegistry {
    self = [super init];
    if (self) {
        _adSessionRegistry = adSessionRegistry;
        _adViews = [NSMutableDictionary new];
        _friendlyObstructionInfo = [NSMutableDictionary new];
        _rootViews = [NSMutableSet new];
        _visibleSessionIds = [NSMutableSet new];
        _hiddenSessionIds = [NSMutableSet new];
    }
    return self;
}

- (void)prepare {
    for (OMIDAdSession *adSession in _adSessionRegistry.activeAdSessions) {        
        UIView *adView = adSession.mainAdView;
        if ([self buildRootViewsFromAdView:adView]) {
            [_visibleSessionIds addObject:adSession.identifier];
            [_adViews setObject:adSession.identifier forKey:[OMIDViewKey viewKeyWithView:adView]];
            [self prepareFriendlyObstructionsForAdSession:adSession];
        } else {
            [_hiddenSessionIds addObject:adSession.identifier];
        }
    }
}

- (BOOL)buildRootViewsFromAdView:(UIView *)adView {
    if (!adView.window) {
        return NO;
    }
    NSMutableSet *temp = [NSMutableSet new];
    UIView *view = adView;
    while (view) {
        if (view.hidden || view.alpha == 0) {
            return NO;
        }
        [temp addObject:view];
        view = view.superview;
    }
    [_rootViews unionSet:temp];
    return YES;
}

- (void)prepareFriendlyObstructionsForAdSession:(OMIDAdSession *)adSession {
    NSArray<OMIDFriendlyObstruction *> *friendlyObstructions = adSession.friendlyObstructions;
    for (OMIDFriendlyObstruction *friendlyObstruction in friendlyObstructions) {
        if (friendlyObstruction.obstructionView != nil) {
            [self addFriendlyObstruction:friendlyObstruction forAdSession:adSession];
        }
    }
}

- (void)addFriendlyObstruction:(OMIDFriendlyObstruction *)friendlyObstruction forAdSession:(OMIDAdSession *)adSession {
    OMIDViewKey *viewKey = [OMIDViewKey viewKeyWithView:friendlyObstruction.obstructionView];
    OMIDObstructionInfo *obstructionInfo = [_friendlyObstructionInfo objectForKey:viewKey];
    if (obstructionInfo == nil) {
        obstructionInfo = [[OMIDObstructionInfo alloc] initWithFriendlyObstruction:friendlyObstruction];
        [_friendlyObstructionInfo setObject:obstructionInfo forKey:viewKey];
    }
    [obstructionInfo.sessionIds addObject:adSession.identifier];
}

- (void)cleanup {
    [_adViews removeAllObjects];
    [_friendlyObstructionInfo removeAllObjects];
    [_rootViews removeAllObjects];
    [_visibleSessionIds removeAllObjects];
    [_hiddenSessionIds removeAllObjects];
    _isAdViewProcessed = NO;
}

- (void)onAdViewProcessed {
    _isAdViewProcessed = YES;
}

- (NSString *)sessionIdForView:(UIView *)view {
    if (_adViews.count == 0) {
        return nil;
    }
    OMIDViewKey *viewKey = [OMIDViewKey viewKeyWithView:view];
    NSString *sessionId = [_adViews objectForKey:viewKey];
    if (sessionId) {
        [_adViews removeObjectForKey:viewKey];
    }
    return sessionId;
}

- (OMIDObstructionInfo *)obstructionInfoForView:(UIView *)view {
    if (_friendlyObstructionInfo.count == 0) {
        return nil;
    }
    OMIDViewKey *viewKey = [OMIDViewKey viewKeyWithView:view];
    OMIDObstructionInfo *obstructionInfo = [_friendlyObstructionInfo objectForKey:viewKey];
    if (obstructionInfo != nil) {
        [_friendlyObstructionInfo removeObjectForKey:viewKey];
    }
    return obstructionInfo;
}

- (OMIDViewType)typeForView:(UIView *)view {
    if ([_rootViews containsObject:view]) {
        return OMIDViewTypeRoot;
    }
    return (_isAdViewProcessed) ? OMIDViewTypeObstruction : OMIDViewTypeUnderlying;
}

- (NSDictionary *)adViews {
    return _adViews;
}

- (NSDictionary *)friendlyObstructionInfo {
    return _friendlyObstructionInfo;
}

- (NSSet *)rootViews {
    return _rootViews;
}

- (NSSet *)visibleSessionIds {
    return _visibleSessionIds;
}

- (NSSet *)hiddenSessionIds {
    return _hiddenSessionIds;
}

@end

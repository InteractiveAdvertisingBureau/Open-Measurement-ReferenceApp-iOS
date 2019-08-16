//
//  OMIDStatePublisher.m
//  AppVerificationLibrary
//
//  Created by Daria on 20/03/17.
//

#import "OMIDStatePublisher.h"
#import "OMIDAdSessionRegistry.h"
#import "OMIDCommand.h"
#import "OMIDDictionaryUtil.h"
#import "OMIDAdSession+Private.h"

@interface OMIDStatePublisher () {
    dispatch_queue_t _queue;
}

@end

@implementation OMIDStatePublisher

- (id)initWithAdSessionRegistry:(OMIDAdSessionRegistry *)adSessionRegistry {
    self = [super init];
    if (self) {
        _adSessionRegistry = adSessionRegistry;
        _queue = dispatch_queue_create("com.iab.omidStatePublisher.serial.queue",
            DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)publishState:(NSMutableDictionary *)state
          toSessions:(NSSet *)sessionIds
          timestamp:(NSTimeInterval)timestamp {
    NSSet *ids = [sessionIds copy];
    dispatch_async(_queue, ^{
        if ([OMIDDictionaryUtil state:state isEqualToState:_previousState]) {
            return;
        }
        _previousState = state;
        NSString *hierarchyString = [OMIDDictionaryUtil stringFromJSON:state];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self publishNativeViewStateHierarchy:hierarchyString
                                       toSessions:ids
                                        timestamp:timestamp];
        });
    });
}

- (void)publishEmptyStateToSessions:(NSSet *)sessionIds timestamp:(NSTimeInterval)timestamp {
    NSSet *ids = [sessionIds copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *hierarchyString =
            [OMIDDictionaryUtil stringFromJSON:[OMIDDictionaryUtil emptyState]];
        [self publishEmptyStateHierarchy:hierarchyString toSessions:ids timestamp:timestamp];
    });
}

- (void)publishNativeViewStateHierarchy:(NSString *)JSONHierarchy
                           toSessions:(NSSet *)sessionIds
                            timestamp:(NSTimeInterval)timestamp {
    // Copy array to avoid reentrancy crashes.
    NSArray *activeAdSessions = [_adSessionRegistry.activeAdSessions copy];
    for (OMIDAdSession *adSession in activeAdSessions) {
        if ([sessionIds containsObject:adSession.identifier]) {
            adSession.lastPublishedViewStateWasPopulated = YES;
            [adSession.statePublisher publishNativeViewStateWithHierarchy:JSONHierarchy
                                                                timestamp:timestamp];
        }
    }
}

- (void)publishEmptyStateHierarchy:(NSString *)JSONHierarchy
                      toSessions:(NSSet *)sessionIds
                       timestamp:(NSTimeInterval)timestamp {
    // Copy array to avoid reentrancy crashes.
    NSArray *activeAdSessions = [_adSessionRegistry.activeAdSessions copy];
    for (OMIDAdSession *adSession in activeAdSessions) {
        if ([sessionIds containsObject:adSession.identifier]) {
            if (adSession.lastPublishedViewStateWasPopulated) {
                adSession.lastPublishedViewStateWasPopulated = NO;
                [adSession.statePublisher publishEmptyNativeViewStateWithHierarchy:JSONHierarchy
                                                                         timestamp:timestamp];
            }
        }
    }
}

- (void)cleanupCache {
    dispatch_async(_queue, ^{
        _previousState = nil;
    });
}

@end

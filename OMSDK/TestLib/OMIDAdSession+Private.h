//
//  OMIDAdSession+Private.h
//  AppVerificationLibrary
//
//  Created by Daria on 06/06/2017.
//

#import "OMIDAdSession.h"
#import "OMIDAdSessionContext.h"
#import "OMIDConstants.h"
#import "OMIDEventFilter.h"
#import "OMIDAdEventsPublisher.h"
#import "OMIDMediaEventsPublisher.h"
#import "OMIDBridge.h"
#import "OMIDAdSessionStatePublisher.h"
#import "OMIDAdSessionDelegate.h"
#import "OMIDFriendlyObstruction.h"

@interface OMIDAdSession () {
    NSMutableArray<OMIDFriendlyObstruction *> *_friendlyObstructions;
    __weak UIView *_mainAdView;
    OMIDAdSessionContext *_context;
}

@property(nonatomic, readonly) NSString *identifier;
@property(nonatomic, readonly) NSArray<OMIDFriendlyObstruction *> *friendlyObstructions;
@property(nonatomic, readonly) OMIDEventFilter *eventFilter;
@property(nonatomic, readonly) id<OMIDAdEventsPublisher> adEventsPublisher;
@property(nonatomic, readonly) id<OMIDMediaEventsPublisher> mediaEventsPublisher;
@property(nonatomic, readonly) OMIDBridge *bridge;
@property(nonatomic, readonly) OMIDAdSessionStatePublisher *statePublisher;
@property(nonatomic, weak) id<OMIDAdSessionDelegate> delegate;
@property(nonatomic) BOOL lastPublishedViewStateWasPopulated;

@end

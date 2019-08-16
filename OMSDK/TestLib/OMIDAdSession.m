//
//  OMIDAdSession.m
//  AppVerificationLibrary
//
//  Created by Daria on 06/06/2017.
//

#import <AVFoundation/AVFoundation.h>
#import "OMIDAdSession+Private.h"
#import "OMIDBridge.h"
#import "OMIDAdSessionContext+Private.h"
#import "OMIDAdSessionRegistry.h"
#import "OMIDEventFilter.h"
#import "OMIDMediaEvents.h"
#import "OMIDAdSessionDelegate.h"
#import "OMIDAdSessionStatePublisher.h"
#import "OMIDMethodInvoker.h"
#import "OMIDJSExecutorFactory.h"
#import "OMIDLightJSExecutor.h"
#import "OMIDError.h"
#import "OMIDManager.h"
#import "OMIDFriendlyObstruction.h"

@implementation OMIDAdSession

- (nullable instancetype)initWithConfiguration:(OMIDAdSessionConfiguration *)configuration adSessionContext:(OMIDAdSessionContext *)context error:(NSError *__autoreleasing  _Nullable *)error {
    self = [super init];
    if (self) {
        if (!context) {
            [OMIDError setOMIDErrorFor:error code:OMIDContextIsNilError message:OMID_CONTEXT_CAN_NOT_BE_NIL_ERROR_MESSAGE];
            return nil;
        }
        _identifier = [NSUUID UUID].UUIDString;
        _context = context;
        _configuration = configuration;
        _friendlyObstructions = [NSMutableArray new];
        _bridge = [[OMIDBridge alloc] initWithJSExecutor:[OMIDJSExecutorFactory JSExecutorForContext:_context]];
        [_bridge publishInitWithConfiguration:configuration];
        _eventFilter = [[OMIDEventFilter alloc] initWithFinalEventCode:OMIDEventCodeFinish];
        _statePublisher = [[OMIDAdSessionStatePublisher alloc] initWithCommandPublisher:_bridge];
        [OMIDMethodInvoker performSelectorAsync:@selector(addToRegistry) target:self];
        _lastPublishedViewStateWasPopulated = YES;
    }
    return self;
}

- (void)addToRegistry {
    [[OMIDAdSessionRegistry getInstance] addAdSession:self];
}

- (NSArray<OMIDFriendlyObstruction *> *)friendlyObstructions {
    return [_friendlyObstructions copy];
}

- (id<OMIDAdEventsPublisher>)adEventsPublisher {
    return _bridge;
}

- (id<OMIDMediaEventsPublisher>)mediaEventsPublisher {
    return _bridge;
}

- (UIView *)mainAdView {
    return _mainAdView;
}

- (void)setMainAdView:(UIView *)mainAdView {
    if (_eventFilter.isFinalEventAccepted) {
        return;
    }
    
    [OMIDMethodInvoker performSelectorSync:@selector(internal_setMainAdView:) target:self argument:mainAdView];
}

- (void)internal_setMainAdView:(UIView *)mainAdView {
    if (_mainAdView == mainAdView) {
        return;
    }
    _mainAdView = mainAdView;
    [_statePublisher cleanupAdState];
    if (mainAdView) {
        [self.delegate adSession:self didRegisterAdView:mainAdView];
    }
}

- (void)start {
    if ([_eventFilter acceptEventWithCode:OMIDEventCodeStart]) {
        [_bridge publishStartEventWithAdSessionId:_identifier JSONContext:[_context toJSON] verificationParameters:[_context resourcesJSON]];
        [self setDeviceVolume];
        [OMIDMethodInvoker performSelectorAsync:@selector(onStart) target:self];
    }
}

- (void)onStart {
    [self.delegate adSessionDidStart:self];
}

- (void)finish {
    if ([_eventFilter acceptEventWithCode:OMIDEventCodeFinish]) {
        [_bridge publishFinishEvent];
        if ([_bridge.jsExecutor isKindOfClass:[OMIDLightJSExecutor class]]) {
            [[(OMIDLightJSExecutor *)_bridge.jsExecutor timer] cancelAllTimers];
        }
        [OMIDMethodInvoker performSelectorAsync:@selector(onFinish) target:self];
    }
}

- (void)onFinish {
    [self.delegate adSessionDidFinish:self];
}

- (void)addFriendlyObstruction:(nonnull UIView *)friendlyObstructionView {
    [self addFriendlyObstruction:friendlyObstructionView purpose:OMIDFriendlyObstructionOther detailedReason:nil error:nil];
}

- (BOOL)addFriendlyObstruction:(nonnull UIView *)friendlyObstructionView
                       purpose:(OMIDFriendlyObstructionType)purpose
                detailedReason:(nullable NSString *)detailedReason
                         error:(NSError *_Nullable *_Nullable)error {
    if (_eventFilter.isFinalEventAccepted) {
        return NO;
    }
    
    if (friendlyObstructionView == nil) {
        [OMIDError setOMIDErrorFor:error code:OMIDFriendlyObstructionIsNilError message:OMID_FRIENDLY_OBSTRUCTION_CAN_NOT_BE_NIL_ERROR_MESSAGE];
        return NO;
    }
    
    NSUInteger index = [self friendlyObstructionIndexForView:friendlyObstructionView];
    if (index != NSNotFound) {
        return NO;
    }
    
    if (detailedReason != nil) {
        NSRegularExpression *detailedReasonRegex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9 ]+$"
                                                                                             options:kNilOptions
                                                                                               error:nil];
        
        if (detailedReason.length > 50 ||
            [detailedReasonRegex numberOfMatchesInString:detailedReason
                                                 options:kNilOptions
                                                   range:NSMakeRange(0, detailedReason.length)] == 0) {
            [OMIDError setOMIDErrorFor:error code:OMIDFriendlyObstructionReasonInvalid message:OMID_FRIENDLY_OBSTRUCTION_REASON_IS_INVALID_ERROR_MESSAGE];
            return NO;
        }
    }
    
    
    if ([NSThread isMainThread]) {
        [self internal_addFriendlyObstruction:friendlyObstructionView purpose:purpose detailedReason:detailedReason];
    } else {
        __weak typeof(self) weakSelf = self;
        __weak typeof(friendlyObstructionView) weakFriendlyObstructionView = friendlyObstructionView;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakFriendlyObstructionView == nil) {
                return;
            }
            
            [weakSelf internal_addFriendlyObstruction:weakFriendlyObstructionView purpose:purpose detailedReason:detailedReason];
        });
    }
    return YES;
}

- (void)internal_addFriendlyObstruction:(nonnull UIView *)friendlyObstructionView purpose:(OMIDFriendlyObstructionType)purpose detailedReason:(nullable NSString *)detailedReason {
    OMIDFriendlyObstruction *friendlyObstruction = [[OMIDFriendlyObstruction alloc] initWithObstructionView:friendlyObstructionView purpose:purpose detailedReason:detailedReason];
    [_friendlyObstructions addObject:friendlyObstruction];
}

- (void)removeFriendlyObstruction:(nonnull UIView *)friendlyObstructionView {
    if (_eventFilter.isFinalEventAccepted) {
        return;
    }
    
    [OMIDMethodInvoker performSelectorAsync:@selector(internal_removeFriendlyObstruction:) target:self argument:friendlyObstructionView];
}

- (void)internal_removeFriendlyObstruction:(nonnull UIView *)friendlyObstruction {
    NSUInteger index = [self friendlyObstructionIndexForView:friendlyObstruction];
    if (index != NSNotFound) {
        [_friendlyObstructions removeObjectAtIndex:index];
    }
}

- (void)removeAllFriendlyObstructions {
    if (_eventFilter.isFinalEventAccepted) {
        return;
    }
    [OMIDMethodInvoker performSelectorAsync:@selector(internal_removeAllFriendlyObstructions) target:self];
}

- (void)internal_removeAllFriendlyObstructions {
    _friendlyObstructions = [NSMutableArray new];
}

- (NSUInteger)friendlyObstructionIndexForView:(UIView *)view {
    return [_friendlyObstructions indexOfObjectPassingTest:^BOOL(OMIDFriendlyObstruction * _Nonnull friendlyObstruction, NSUInteger index, BOOL * _Nonnull stop) {
        return friendlyObstruction.obstructionView == view;
    }];
}

- (void)logErrorWithType:(OMIDErrorType)errorType message:(nonnull NSString *)message {
    if (message.length > 0 && [_eventFilter acceptAnyEventWithRequiredEventCodes:0]) {        
        [_bridge publishErrorWithType:errorType errorMessage:message];
    }
}

- (void)setDeviceVolume {
    [_statePublisher publishDeviceVolume:[self deviceVolume]];
}

- (CGFloat)deviceVolume {
    return [AVAudioSession sharedInstance].outputVolume;
}
@end

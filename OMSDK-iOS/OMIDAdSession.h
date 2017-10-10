//
//  OMIDAdSession.h
//  AppVerificationLibrary
//
//  Created by Daria on 06/06/2017.
//

#import <UIKit/UIKit.h>
#import "OMIDAdSessionContext.h"
#import "OMIDAdSessionConfiguration.h"

typedef enum OMIDErrorType : NSUInteger {
    OMIDErrorGeneric = 1, // will translate into "GENERIC" when published to the OMID JS service.
    OMIDErrorVideo = 2 // will translate into "VIDEO" when published to the OMID JS service.
} OMIDErrorType;

/*!
 * @discussion Ad session API enabling the integration partner to notify OMID of key state relating to viewability calculations.
 * In addition to viewability this API will also notify all verification providers of key ad session lifecycle events.
 */
@interface OMIDAdSession : NSObject

/*!
 * @abstract The AdSession configuration is used for check owners.
 */
@property(nonatomic, readonly, nonnull) OMIDAdSessionConfiguration *configuration;
/*!
 * @abstract The native view which is used for viewability tracking.
 */
@property(nonatomic, weak, nullable) UIView *mainAdView;

/*!
 * @abstract Initializes new ad session supplying the context.
 *
 * @param context The context that provides the required information for initialising the ad session.
 * @return A new OMIDAdSession instance, or nil if the supplied context is nil.
 */
- (nullable instancetype)initWithConfiguration:(nonnull OMIDAdSessionConfiguration *)configuration
                              adSessionContext:(nonnull OMIDAdSessionContext *)context
                                         error:(NSError *_Nullable *_Nullable)error;


/*!
 * @abstract Notifies all verification providers that the ad session has started and ad view tracking will begin.
 * 
 * @discussion This method will have no affect if called after the ad session has finished.
 */
- (void)start;

/*!
 * @abstract Notifies all verification providers that the ad session has finished and all ad view tracking will stop.
 *
 * @discussion This method will have no affect if called after the ad session has finished.
 */
- (void)finish;

/*!
 * @abstract Adds friendly obstruction which should then be excluded from all ad session viewability calculations.
 *
 * @discussion This method will have no affect if called after the ad session has finished.
 *
 * @param friendlyObstruction The view to be excluded from all ad session viewability calculations.
 */
- (void)addFriendlyObstruction:(nonnull UIView *)friendlyObstruction;

/*!
 * @abstract Removes registered friendly obstruction.
 *
 * @discussion This method will have no affect if called after the ad session has finished.
 *
 * @param friendlyObstruction The view to be removed from the list of registered friendly obstructions.
 */
- (void)removeFriendlyObstruction:(nonnull UIView *)friendlyObstruction;

/*!
 * @abstract Utility method to remove all registered friendly obstructions.
 *
 * @discussion This method will have no affect if called after the ad session has finished.
 */
- (void)removeAllFriendlyObstructions;

/*!
 * @abstract Notifies the ad session that an error has occurred.
 *
 * @discussion When triggered all registered verification providers will be notified of this event.
 *
 * @param errorType The type of error.
 * @param message The message containing details of the error.
 */
- (void)logErrorWithType:(OMIDErrorType)errorType message:(nonnull NSString *)message;

@end


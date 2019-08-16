//
//  OMIDAdViewCache.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 02/02/17.
//

#import <UIKit/UIKit.h>
#import "OMIDAdSession.h"
#import "OMIDObstructionInfo.h"

/*!
 * @abstract A list of view types.
 * @constant OMIDViewTypeRoot Ad view or ad view's parent.
 * @constant OMIDViewTypeObstruction View with higher z position than ad view's z position.
 * @constant OMIDViewTypeUnderlying View with lower z position than ad view's z position.
 */
typedef enum OMIDViewType : NSUInteger {
    OMIDViewTypeRoot,
    OMIDViewTypeObstruction,
    OMIDViewTypeUnderlying
} OMIDViewType;

@class OMIDAdSessionRegistry;

/*!
 * @discussion Utility which prepares and provides information used during building native view hierarchy.
 */
@interface OMIDAdViewCache : NSObject

/*!
 * @abstract Ad session registry providing ad sessions.
 */
@property(nonatomic, readonly) OMIDAdSessionRegistry *adSessionRegistry;

/*!
 * @abstract A dictionary with ad views as keys and ad session ids as values.
 *
 * @discussion This property contains only visible views.
 */
@property(nonatomic, readonly) NSDictionary *adViews;

/*!
 * @abstract A dictionary with friendly obstructions as keys and arrays of ad session ids as values.
 *
 * @discussion This property contains only ids of ad sessions with visible ad views.
 */
@property(nonatomic, readonly) NSDictionary *friendlyObstructionInfo;

/*!
 * @abstract A set containing view with OMIDViewTypeRoot type.
 *
 * @discussion This property contains only visible views.
 */
@property(nonatomic, readonly) NSSet *rootViews;

/*!
 * @abstract A set containing ids of ad sessions with visible ad views.
 */
@property(nonatomic, readonly) NSSet *visibleSessionIds;

/*!
 * @abstract A set containing ids of ad sessions with hidden ad views.
 */
@property(nonatomic, readonly) NSSet *hiddenSessionIds;

/*!
 * @abstract Initializes ad view cache with provided ad session registry.
 *
 * @param adSessionRegistry Ad session registry instance.
 * @return A new ad view cache instance.
 */
- (id)initWithAdSessionRegistry:(OMIDAdSessionRegistry *)adSessionRegistry;

/*!
 * @abstract Fills all properties (adViews, friendlyObstructions, etc.) using active ad sessions from ad session registry.
 *
 * @discussion This method is called before each tree walker's iteration. Only active (started) ad sessions are processed.
 */
- (void)prepare;

/*!
 * @abstract Removes all data from all properties (adViews, friendlyObstructions, etc.)
 *
 * @discussion This method is called after each tree walker's iteration.
 */
- (void)cleanup;

/*!
 * @abstract Tells that ad view has been processed during building native view hierarchy.
 *
 * @discussion This method is called each time when tree walker finds an ad view in the view hierarchy. This is needed to detect whether a view is obstruction or underlying view.
 */
- (void)onAdViewProcessed;

/*!
 * @abstract Returns ad session id for the provided view.
 *
 * @param view The view.
 * @return Id of the ad session provided view is registered with. Returns nil if the view is not an ad view.
 */
- (NSString *)sessionIdForView:(UIView *)view;

/*!
 * @abstract Returns the relevant obstruction info for a given view.
 *
 * @param view The view.
 * @return The obstruction info for the given view.. Returns nil if the view is not a friendly obstruction.
 */
- (OMIDObstructionInfo *)obstructionInfoForView:(UIView *)view;

/*!
 * @abstract Detects the type of provided view.
 *
 * @param view The view.
 * @return The view type.
 */
- (OMIDViewType)typeForView:(UIView *)view;

// Private methods

/*!
* @abstract Adds ad view and ad view parents to root views.
*
* @discussion Ad view is detected as visible if it is attached to window and it and all its parents are visible (hidden is NO and alpha != 0). Otherwise ad view is detected as hidden and it and its parents are not added to root views.
*
* @param adView view The ad view.
* @return YES if the ad view is visible and is added to root views with its parent. Returns NO if the ad view is hidden.
*/
- (BOOL)buildRootViewsFromAdView:(UIView *)adView;

/*!
 * @abstract Fills friendly obstructions dictionary with friendly obstructions of provided ad sessions.
 *
 * @param adSession The ad session.
 */
- (void)prepareFriendlyObstructionsForAdSession:(OMIDAdSession *)adSession;

/*!
 * @abstract Adds friendly obstruction and ad session to friendly obstructions dictionary.
 *
 * @param friendlyObstruction The friendly obstruction.
 * @param adSession The ad session containing friendly obstruction.
 */
- (void)addFriendlyObstruction:(OMIDFriendlyObstruction *)friendlyObstruction forAdSession:(OMIDAdSession *)adSession;

@end

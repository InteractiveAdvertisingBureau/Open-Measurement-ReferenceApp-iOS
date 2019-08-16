//
//  OMIDTreeWalker.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 24/07/15.
//

#import <UIKit/UIKit.h>
#import "OMIDAdViewCache.h"
#import "OMIDNodeProcessor.h"

@protocol OMIDTreeWalkerTimeLogger <NSObject>

- (void)didProcessObjectsCount:(NSInteger)count withTime:(CGFloat)time;

@end

/*!
 * @discussion Tree walker is responsible for building native view hierarchy.
 */
@interface OMIDTreeWalker : NSObject

@property(nonatomic, weak) id<OMIDTreeWalkerTimeLogger> timeLogger;

/*!
 * @abstract Shared OMIDTreeWalker instance.
 */
+ (OMIDTreeWalker *)getInstance;

/*!
 * @abstract Starts polling job.
 * 
 * @discussion Tree walker builds native view hierarchy each 200 ms.
 */
- (void)start;

/*!
 * @abstract Stops polling job.
 *
 * @discussion This method stops polling job and cleanups last published native view hierarchy.
 */
- (void)stop;

/*!
 * @abstract Pauses polling job.
 *
 * @discussion This method stops polling job but keeps last published native view hierarchy.
 */
- (void)pause;

// Private methods

/*!
 * @abstract Builds current native view hierarchy.
 *
 * @discussion Tree walker will build native view hierarchy only if there is at least one ad session with visible ad view. Tree walker publishes native view hierarchy only to ad sessions with visible ad views because they are presented in this hierarchy. Hidden views are not included to the hierarchy. Tree walker publishes empty native view hierarchy to ad sessions with hidden ad views.
 */
- (void)doWalk;

/*!
 * @abstract Builds native state for provided view.
 *
 * @discussion Tree walker builds native state for provided view and adds to the parent state. Tree walker will skip this view and will not include it to the hierarchy if it is hidden or if it has OMIDViewTypeUnderlying type. Underlying views are located under all ad views and do not impact their viewability.
 *
 * @param view The view to be processed.
 * @param processor The node processor for provided view.
 * @param parentState The native state of provided view's superview.
 */
- (void)walkView:(UIView *)view processor:(id<OMIDNodeProcessor>)processor parentState:(NSMutableDictionary *)parentState;

/*!
 * @abstract Builds native states for subviews of provided view.
 *
 * @discussion Tree walker iterates view's subviews and builds native states for them. Tree walker will sort subviews by z position if view has OMIDViewTypeRoot type. Tree walker will not sort subviews by z position if view has OMIDViewTypeObstruction type because obstruction view does not contain any ad view in its own hierarchy so the order of its subviews does not impact viewability calculation.
 *
 * @param view The view which subviews should be processed.
 * @param processor The node processor for provided view.
 * @param state The native state of provided view.
 * @param type The view's type.
 */
- (void)walkChildrenForView:(UIView *)view processor:(id<OMIDNodeProcessor>)processor state:(NSMutableDictionary *)state type:(OMIDViewType)type;

/*!
 * @abstract Checks whether provided view is ad view.
 *
 * @discussion Tree walker will add ad session id to native state if the view is ad view.
 *
 * @param view The view.
 * @param state The native state of provided view.
 * @return YES if provided view is ad view, NO otherwise.
 */
- (BOOL)handleAdView:(UIView *)view withState:(NSMutableDictionary *)state;

/*!
 * @abstract Checks whether provided view is friendly obstruction for one or more ad sessions.
 *
 * @discussion Tree walker will the list of friendly session ids to native state if the view is friendly obstruction.
 *
 * @param view The view.
 * @param state The native state of provided view.
 */
- (void)checkFriendlyObstruction:(UIView *)view withState:(NSMutableDictionary *)state;
@end

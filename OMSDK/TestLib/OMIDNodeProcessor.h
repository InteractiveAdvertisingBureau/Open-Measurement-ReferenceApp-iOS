//
//  OMIDViewNodeProcessor.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/10/15.
//

@class UIView;

/*!
 * @discussion Node processor provides information about views when OMID builds native view hierarchy.
 */
@protocol OMIDNodeProcessor <NSObject>

/*!
 * @abstract Property contains the processor for child elements.
 */
@property(nonatomic, weak) id<OMIDNodeProcessor> processorForChildren;

/*!
 * @abstract Creates native state for provided view.
 *
 * @param view The view to be processed.
 * @return Native view state in JSON format.
 */
- (NSMutableDictionary *)stateForView:(UIView *)view;

/*!
 * @abstract Builds the list of subviews without sorting them by z position.
 *
 * @param view The view to be processed.
 * @return The list of subviews.
 */
- (NSArray *)childrenForView:(UIView *)view;

/*!
 * @abstract Builds the list of subviews with sorting them by z position.
 *
 * @param view The view to be processed.
 * @return The sorted list of subviews.
 */
- (NSArray *)orderedChildrenForView:(UIView *)view;

@end

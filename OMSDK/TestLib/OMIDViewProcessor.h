//
//  OMIDViewProcessor.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/10/15.
//

#import <UIKit/UIKit.h>
#import "OMIDNodeProcessor.h"

/*!
 * @discussion Node processor for UIView.
 */
@interface OMIDViewProcessor : NSObject <OMIDNodeProcessor>

@property(nonatomic, weak) id<OMIDNodeProcessor> processorForChildren;

/*!
 * @abstract Converts view frame to its window coordinate system.
 *
 * @param view The view to be processed.
 * @return View frame in its window coordinate system.
 */
- (CGRect)frameInWindowSystemForView:( UIView *)view;

/*!
 * @abstract Returns window of provided view.
 *
 * @param view The view to be processed.
 * @return The window of the view.
 */
- (UIWindow *)windowForView:(UIView *)view;

@end

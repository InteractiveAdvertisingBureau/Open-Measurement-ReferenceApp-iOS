//
//  OMIDAdSessionDelegate.h
//  AppVerificationLibrary
//
//  Created by Daria on 06/07/2017.
//

#import <UIKit/UIKit.h>
#import "OMIDAdSession.h"

/*!
 * @discussion Ad session notifies delegate about session events.
 */
@protocol OMIDAdSessionDelegate <NSObject>

/*!
 * @abstract Tells the delegate that ad session started.
 *
 * @param adSession The ad session informing the delegate.
 */
- (void)adSessionDidStart:(OMIDAdSession *)adSession;

/*!
 * @abstract Tells the delegate that ad session finished.
 *
 * @param adSession The ad session informing the delegate.
 */
- (void)adSessionDidFinish:(OMIDAdSession *)adSession;

/*!
 * @abstract Tells the delegate that ad session registered ad view.
 *
 * @param adSession The ad session informing the delegate.
 * @param adView Registered ad view.
 */
- (void)adSession:(OMIDAdSession *)adSession didRegisterAdView:(UIView *)adView;

@end

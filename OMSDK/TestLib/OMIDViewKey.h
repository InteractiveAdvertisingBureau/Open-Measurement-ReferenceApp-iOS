//
//  OMIDViewKey.h
//  AppVerificationLibrary
//
//  Created by Daria on 15/03/17.
//

#import <UIKit/UIKit.h>

/*!
 * @discussion Utility allowing to use UIView as a key for NSDictionary.
 */
@interface OMIDViewKey : NSObject<NSCopying>

/*
 * @abstract The view used as a key.
 */
@property(nonatomic, strong) UIView *view;

/*!
 * @abstract Initializes a wrapper to a view object to use as a dictionary key.
 *
 * @param view The view to be wrapped.
 * @return A new OMIDViewKey instance.
 */

+ (nonnull instancetype)viewKeyWithView:(UIView *)view;

@end

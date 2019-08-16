//
//  OMIDProcessorFactory.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/10/15.
//

#import <Foundation/Foundation.h>

#import "OMIDNodeProcessor.h"

/*!
 * @discussion Utility to create node processors.
 */
@interface OMIDProcessorFactory : NSObject

/*!
 * @abstract Creates node processor for the root element of the native view hierarchy.
 *
 * @discussion The root element is always UIScreen.mainScreen.
 *
 * @return Node processor for the root element.
 */
- (id<OMIDNodeProcessor>)rootProcessor;

@end

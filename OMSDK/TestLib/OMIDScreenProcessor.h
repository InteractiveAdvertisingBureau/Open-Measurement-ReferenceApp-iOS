//
//  OMIDScreenProcessor.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/10/15.
//

#import <Foundation/Foundation.h>
#import "OMIDNodeProcessor.h"

/*!
 * @discussion Node processor for UIScreen.
 */
@interface OMIDScreenProcessor : NSObject <OMIDNodeProcessor>

@property(nonatomic, weak) id<OMIDNodeProcessor> processorForChildren;

@end

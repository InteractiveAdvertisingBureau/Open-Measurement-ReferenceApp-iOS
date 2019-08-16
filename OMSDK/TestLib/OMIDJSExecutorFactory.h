//
//  OMIDJSExecutorFactory.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 23/06/2017.
//

#import <Foundation/Foundation.h>
#import "OMIDJSExecutor.h"
#import "OMIDAdSessionContext.h"

/*!
 * @discussion Utility responsible for creating OMIDJSExecutor instances.
 */
@interface OMIDJSExecutorFactory : NSObject

/*!
 * @abstract Creates OMIDJSExecutor instance for provided ad session context.
 *
 * @param context The ad session context.
 * @return OMIDJSExecutor instance related to provided ad session context.
 */
+ (id<OMIDJSExecutor>)JSExecutorForContext:(OMIDAdSessionContext *)context;

@end

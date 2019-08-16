//
// Created by Daria Sukhonosova on 20/04/16.
//

#import <Foundation/Foundation.h>

/*!
 * @discussion Provides information about the application common to all ad sessions.
 */
@interface OMIDContext : NSObject

/*!
 * @abstract Shared OMIDContext instance.
 */
@property(class, readonly) OMIDContext *sharedContext;

/*!
 * @abstract Returns application specific properties in JSON format.
 *
 * @return JSON containing application specific properties.
 */
- (NSDictionary *)toJSON;

@end

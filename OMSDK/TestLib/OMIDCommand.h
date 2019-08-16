//
//  OMIDCommand.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 23/07/15.
//

#import <UIKit/UIKit.h>
#import "OMIDAdSession.h"

#define INIT_SESSION @"init"
#define START_SESSION @"startSession"
#define FINISH_SESSION @"finishSession"
#define SET_NATIVE_VIEW_HIERARCHY @"setNativeViewHierarchy"
#define SET_APP_STATE @"setState"
#define PUBLISH_IMPRESSION_EVENT @"publishImpressionEvent"
#define PUBLISH_LOADED_EVENT @"publishLoadedEvent"
#define PUBLISH_MEDIA_EVENT @"publishMediaEvent"
#define SET_DEVICE_VOLUME @"setDeviceVolume"
#define ERROR @"error"

/*!
 * @discussion Utility to build commands to OMID JS.
 */
@interface OMIDCommand : NSObject

/*!
 * @abstract Builds the command to OMID JS.
 *
 * @param name The command name.
 * @param ... A comma-separated list of the command arguments, ending with nil.
 * @return A string containing the command.
 */
+ (NSString *)commandWithName:(NSString *)name,...NS_REQUIRES_NIL_TERMINATION;

/*!
 * @abstract Builds a command that logs an error to OMID JS.
 *
 * @param type The error type (video or generic).
 * @param message The text of the error message.
 * @return A string containing the command.
 */
+ (NSString *)errorCommandWithType:(OMIDErrorType)type errorMessage:(NSString *)message;

/*!
 * @abstract Surrounds the provided string with quotes.
 *
 * @param string The string.
 * @return A string with quotes.
 */
+ (NSString *)stringWithQuotesFromString:(NSString *)string;

/*!
 * @abstract Escapes the contents of a string for use in a command.
 *
 * @param string The string.
 * @return A string wrapped in quotes and with special characters escaped with backslashes.
 */
+ (NSString *)escapedString:(NSString *)string;

@end


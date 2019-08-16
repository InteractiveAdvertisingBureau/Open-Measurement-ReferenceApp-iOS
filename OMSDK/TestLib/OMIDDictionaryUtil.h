//
//  NSDictionary+Omid.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 06/08/15.
//

#import "OMIDObstructionInfo.h"

/*!
 * @discussion Utility to build native view states.
 */
@interface OMIDDictionaryUtil : NSObject

/*!
 * @abstract Builds native state for one element.
 *
 * @param frame The element frame.
 * @param clipsToBounds The clipsToBounds property.
 * @return Native state in JSON format.
 */
+ (NSMutableDictionary *)stateWithFrame:(CGRect)frame clipsToBounds:(BOOL)clipsToBounds;

/*!
 * @abstract Adds obstruction info to provided native state.
 *
 * @param state The native state.
 * @param obstructionInfo The obstruction info to append.
 */
+ (void)state:(NSMutableDictionary *)state addObstructionInfo:(OMIDObstructionInfo *)obstructionInfo;

/*!
 * @abstract Adds ad session id to provided native state.
 *
 * @param state The native state.
 * @param sessionId The ad session id.
 */
+ (void)state:(NSMutableDictionary *)state addSessionId:(NSString *)sessionId;

/*!
 * @abstract Adds child state to provided native state.
 *
 * @param state The native state.
 * @param childState The child state.
 */
+ (void)state:(NSMutableDictionary *)state addChildState:(NSMutableDictionary *)childState;

/*!
 * @abstract Compares native states.
 *
 * @param state The first state.
 * @param anotherState The second state.
 * @return YES if states are equal, NO otherwise.
 */
+ (BOOL)state:(NSMutableDictionary *)state isEqualToState:(NSMutableDictionary *)anotherState;

/*!
 * @abstract Creates empty native view state.
 *
 * @return Empty native view state.
 */
+ (NSDictionary *)emptyState;

/*!
 * @abstract Converts JSON object to the string.
 *
 * @param json JSON object, must be NSDictionary or NSArray.
 * @return The string representing provided JSON object.
 */
+ (NSString *)stringFromJSON:(id)json;

/*!
 * @abstract Converts a friendly obstruction type to a string.
 *
 * @param obstructionType The obstruction type that the view represents.
 * @return The string representing the obstruction type.
 */
+ (NSString *)stringFromObstructionType:(OMIDFriendlyObstructionType)obstructionType;
@end

//
//  OMIDSDK.h
//  AppVerificationLibrary
//
//  Created by Daria on 05/06/2017.
//

#import <Foundation/Foundation.h>

typedef NSString *OMIDAPIVersion;

/// API Note: this value must be copied into the ad SDK's binary. It cannot be an extern defined in
/// the OMID library.
#define OMIDSDKAPIVersionString ((OMIDAPIVersion) @"{\"v\":\"1.0.0\",\"a\":\"1\"}")

/*!
 * @discussion This application level class will be called by all integration partners to ensure OM SDK has been activated before calling any other API methods.
 * Any attempt to use other API methods prior to activation will result in an error.
 */
@interface OMIDSDK : NSObject

/*!
 * @abstract The current semantic version of the integrated OMID library.
 */
+ (nonnull NSString *)versionString;

/*!
 * @abstract Allows the integration partner to check that they are compatible with the running OMID library version.
 *
 * @param OMIDAPIVersionString The version of OMID library integrated by the partner.
 * @return YES if the version supplied is compatible with the integrated OMID library version.
 */

+ (BOOL)isCompatibleWithOMIDAPIVersion:(nonnull OMIDAPIVersion)OMIDAPIVersionString;

/*!
 * @abstract Shared OMIDSDK instance.
 */
@property(class, readonly, nonnull) OMIDSDK *sharedInstance;

/*!
 * @abstract A Boolean value indicating whether the OMID library has been activated.
 *
 * @discussion The value of this property is YES if the OMID library has already been activated. Allows the integration partner to check that they are compatible with the running OMID library version.
 */
@property(atomic, readonly, getter = isActive) BOOL active;

/*!
 * @abstract Enables the integration partner to activate OMID prior to calling any other API methods.
 *
 * @param OMIDAPIVersion The version of OMID library integrated by the partner.
 * @param error If an error occurs, contains an NSError object that describes the problem.
 * @return YES if activation was successful when checking the supplied version number for compatibility.
 */
- (BOOL)activateWithOMIDAPIVersion:(nonnull OMIDAPIVersion)OMIDAPIVersion
                             error:(NSError *_Nullable *_Nullable)error;

@end

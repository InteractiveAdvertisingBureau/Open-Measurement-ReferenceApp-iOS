//
//  OMIDDevice.h
//  AppVerificationLibrary
//
//  Created by Chris Troein on 2/23/18.
//

#import <Foundation/Foundation.h>

@interface OMIDDevice : NSObject

+ (instancetype)new __unavailable;
- (instancetype)init __unavailable;

/*!
 * @abstract stores deviceDictionary to mimizize unnecessary system calls. Values should be individually accessed to ensure that they can be individually mocked.
 *
 * @return dictionary consisting of device information.
 */
+ (NSDictionary *)deviceDictionary;

/*!
 * @abstract Returns device type in a method that is friendly for unit testing in OCMock.
 *
 * @return NSString with device type information.
 */
+ (NSString *)deviceType;

/*!
 * @abstract Returns device OS in a method that is friendly for unit testing in OCMock. In practice, this is always "iOS".
 *
 * @return NSString with device OS information.
 */
+ (NSString *)deviceOs;


/*!
 * @abstract Returns device OS version in a method that is friendly for unit testing in OCMock.
 *
 * @return NSString with device OS version information.
 */
+ (NSString *)deviceOsVersion;


/*!
 * @abstract Returns device OS version in a method that is friendly for unit testing in OCMock.
 *
 * @return NSString with device OS version information.
 */
+ (NSDictionary *)toJSON;


@end

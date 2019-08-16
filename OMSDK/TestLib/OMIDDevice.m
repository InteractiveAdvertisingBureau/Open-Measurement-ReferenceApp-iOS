//
//  OMIDDevice.m
//  AppVerificationLibrary
//
//  Created by Chris Troein on 2/23/18.
//

#import "OMIDDevice.h"
#import "OMIDConstants.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>

@implementation OMIDDevice

+ (NSDictionary *)deviceDictionary {
    static NSDictionary *dict = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        dict = @{
                 CONTEXT_DEVICE_TYPE : [self deviceType],
                 CONTEXT_DEVICE_OS : [self deviceOs],
                 CONTEXT_DEVICE_OS_VERSION : [self deviceOsVersion]
                 };
    });
    
    return dict;
}

+ (NSString *)deviceType {
    struct utsname systemInfo;
    if (uname(&systemInfo) != 0){
        return CONTEXT_NA_VALUE;
    }

    NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if (machine != nil) {
        return machine;
    }
    return CONTEXT_NA_VALUE;
}

+ (NSString *)deviceOs {
    NSString *os = [[UIDevice currentDevice] systemName];
	if (os != nil) {
		return os;
    }
    return CONTEXT_NA_VALUE;
}

+ (NSString *)deviceOsVersion {
   	NSString *version = [[UIDevice currentDevice] systemVersion];
    if (version != nil) {
        return version;
    }
    return CONTEXT_NA_VALUE;
}

+ (NSDictionary *)toJSON {
    NSDictionary *result = [OMIDDevice deviceDictionary];
    return result;
}

@end

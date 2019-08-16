//
//  OMIDSDK.m
//  AppVerificationLibrary
//
//  Created by Daria on 05/06/2017.
//

#import "OMIDSDK.h"
#import "OMIDManager.h"
#import "OMIDConstants.h"
#import "OMIDError.h"

#define KEY_VERSION @"v"

@implementation OMIDSDK

+ (NSString *)versionString {
    NSString *partnerVersionStr = [NSString stringWithFormat: @"%@-%@", @"1.0.2", @"IAB"];
    return partnerVersionStr;
}

+ (BOOL)isCompatibleWithOMIDAPIVersion:(NSString *)OMIDAPIVersionString {
    NSDictionary *temp = [NSJSONSerialization JSONObjectWithData:[OMIDAPIVersionString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    if (!temp) {
        return NO;
    }
    NSString *version = [temp objectForKey:KEY_VERSION];
    NSInteger currentMajorVersion = [self majorVersionFrom:[self versionString]];
    NSInteger majorVersion = [self majorVersionFrom:version];
    return majorVersion == currentMajorVersion;
}

+ (NSInteger)majorVersionFrom:(NSString *)releaseVersion {
    return [[[releaseVersion componentsSeparatedByString:@"."] firstObject] integerValue];
}

+ (OMIDSDK *)sharedInstance {
    static dispatch_once_t onceToken;
    static OMIDSDK *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [OMIDSDK new];
    });
    return sharedInstance;
}

- (BOOL)activateWithOMIDAPIVersion:(nonnull NSString *)OMIDAPIVersion
                             error:(NSError *_Nullable *_Nullable)error {
    return [self activate];
}

- (BOOL)activate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[OMIDManager getInstance] setup];
    });
    _active = YES;
    return YES;
}

@end

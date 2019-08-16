//
//  OMIDPartner.m
//  AppVerificationLibrary
//
//  Created by Daria on 06/06/2017.
//

#import "OMIDPartner.h"
#import "OMIDConstants.h"

@implementation OMIDPartner

- (nullable instancetype)initWithName:(nonnull NSString *)name
                        versionString:(nonnull NSString *)versionString; {
    self = [super init];
    if (self) {
        if (name.length == 0 || versionString.length == 0) {
            return nil;
        }
        _name = [name copy];
        _versionString = [versionString copy];
    }
    return self;
}

- (NSDictionary *)toJSON {
    return @{CONTEXT_PARTNER_NAME : _name, CONTEXT_PARTNER_VERSION : _versionString};
}

@end

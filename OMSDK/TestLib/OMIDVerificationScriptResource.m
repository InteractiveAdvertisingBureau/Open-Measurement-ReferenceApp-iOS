//
//  OMIDVerificationScriptResource.m
//  AppVerificationLibrary
//
//  Created by Daria on 06/06/2017.
//

#import "OMIDVerificationScriptResource.h"

@implementation OMIDVerificationScriptResource

- (nullable instancetype)initWithURL:(nonnull NSURL *)URL
                           vendorKey:(nonnull NSString *)vendorKey
                          parameters:(nonnull NSString *)parameters {
    self = [super init];
    if (self) {
        if (URL.absoluteString.length == 0 || vendorKey.length == 0 || parameters.length == 0) {
            return nil;
        }
        _URL = URL;
        _vendorKey = [vendorKey copy];
        _parameters = [parameters copy];
    }
    return self;
}

- (nullable instancetype)initWithURL:(nonnull NSURL *)URL {
    self = [super init];
    if (self) {
        if (URL.absoluteString.length == 0) {
            return nil;
        }
        _URL = URL;
    }
    return self;
}

@end

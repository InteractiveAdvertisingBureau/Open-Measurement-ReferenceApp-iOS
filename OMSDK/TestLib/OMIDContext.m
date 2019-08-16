//
// Created by Daria Sukhonosova on 20/04/16.
//

#import "OMIDContext.h"
#import "OMIDConstants.h"
#import "OMIDSDK.h"

@implementation OMIDContext

+ (OMIDContext *)sharedContext {
    static dispatch_once_t pred = 0;
    __strong static OMIDContext *context;
    dispatch_once(&pred, ^{
        context = [[self alloc] init];
    });
    return context;
}

- (NSDictionary *)toJSON {
    return @{CONTEXT_APP_ID : [NSBundle mainBundle].bundleIdentifier, CONTEXT_LIBRARY_VERSION : [OMIDSDK versionString]};
}

@end

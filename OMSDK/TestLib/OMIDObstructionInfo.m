//
//  OMIDObstructionInfo.m
//  AppVerificationLibrary
//
//  Created by Andrew Whitcomb on 4/3/19.
//  Copyright © 2019 Integral Ad Science, Inc. All rights reserved.
//

#import "OMIDObstructionInfo.h"

@implementation OMIDObstructionInfo

- (nonnull instancetype)initWithFriendlyObstruction:(OMIDFriendlyObstruction *)friendlyObstruction {
    self = [super init];
    if (self) {
        _friendlyObstruction = friendlyObstruction;
        _sessionIds = [NSMutableSet new];
    }
    return self;
}

@end

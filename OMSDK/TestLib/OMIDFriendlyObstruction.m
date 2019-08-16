//
//  OMIDFriendlyObstruction.m
//  AppVerificationLibrary
//
//  Created by Andrew Whitcomb on 4/3/19.
//  Copyright © 2019 Integral Ad Science, Inc. All rights reserved.
//

#import "OMIDFriendlyObstruction.h"

@interface OMIDFriendlyObstruction () {
    __weak UIView *_obstructionView;
    NSString *_obstructionViewClass;
    OMIDFriendlyObstructionType _purpose;
    NSString *_detailedReason;
}

@end

@implementation OMIDFriendlyObstruction

- (nullable instancetype)initWithObstructionView:(nonnull UIView *)obstructionView purpose:(OMIDFriendlyObstructionType)purpose detailedReason:(nullable NSString *)detailedReason {
    self = [super init];
    if (self) {
        _obstructionView = obstructionView;
        _obstructionViewClass = NSStringFromClass(obstructionView.class);
        _purpose = purpose;
        _detailedReason = [detailedReason copy];
    }
    return self;
}

@end

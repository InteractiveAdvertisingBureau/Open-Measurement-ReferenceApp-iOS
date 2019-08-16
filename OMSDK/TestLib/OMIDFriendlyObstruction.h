//
//  OMIDFriendlyObstruction.h
//  AppVerificationLibrary
//
//  Created by Andrew Whitcomb on 4/3/19.
//  Copyright © 2019 Integral Ad Science, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMIDFriendlyObstructionType.h"

@interface OMIDFriendlyObstruction : NSObject

@property (weak, nonatomic, readonly) UIView *_Nullable obstructionView;
@property (nonatomic, readonly) NSString *_Nonnull obstructionViewClass;
@property (nonatomic, readonly) OMIDFriendlyObstructionType purpose;
@property (nonatomic, readonly) NSString *_Nullable detailedReason;

- (nullable instancetype)initWithObstructionView:(nonnull UIView *)obstructionView purpose:(OMIDFriendlyObstructionType)purpose detailedReason:(nullable NSString *)detailedReason;

@end

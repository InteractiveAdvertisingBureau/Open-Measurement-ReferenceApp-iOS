//
//  OMIDObstructionInfo.h
//  AppVerificationLibrary
//
//  Created by Andrew Whitcomb on 4/3/19.
//  Copyright © 2019 Integral Ad Science, Inc. All rights reserved.
//

#import "OMIDFriendlyObstruction.h"

@interface OMIDObstructionInfo : NSObject

@property (strong, nonatomic, readonly) OMIDFriendlyObstruction *friendlyObstruction;
@property (strong, nonatomic, readonly) NSMutableSet<NSString *> *sessionIds;

- (nonnull instancetype)initWithFriendlyObstruction:(nonnull OMIDFriendlyObstruction *)friendlyObstruction;

@end

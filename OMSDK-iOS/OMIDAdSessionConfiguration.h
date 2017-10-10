//
//  OMIDAdSessionConfiguration.h
//  AppVerificationLibrary
//
//  Created by Saraev Vyacheslav on 15/09/2017.
//

#import <UIKit/UIKit.h>

typedef enum OMIDOwner : NSUInteger {
    OMIDJavaScriptOwner = 1, // will translate into "JAVASCRIPT" when published to the OMID JS service.
    OMIDNativeOwner = 2, // will translate into "NATIVE" when published to the OMID JS service.
    OMIDNoneOwner = 3 // will translate into "NONE" when published to the OMID JS service.
} OMIDOwner;

@interface OMIDAdSessionConfiguration : NSObject

@property OMIDOwner impressionOwner;
@property OMIDOwner videoEventsOwner;

/// Returns nil and sets error if OMID isn't active or arguments are invalid.
/// @param impressionOwner providing details of who is responsible for triggering the impression event.
/// @param videoEventsOwner providing details of who is responsible for triggering video events. This is only required for video ad sessions.
- (nullable instancetype)initWithImpressionOwner:(OMIDOwner)impressionOwner
                                videoEventsOwner:(OMIDOwner)videoEventsOwner
                                           error:(NSError *_Nullable *_Nullable)error;

@end


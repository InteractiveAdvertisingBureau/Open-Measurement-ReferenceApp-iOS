//
//  OMIDAdSessionConfiguration.h
//  AppVerificationLibrary
//
//  Created by Saraev Vyacheslav on 15/09/2017.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, OMIDOwner) {
    OMIDJavaScriptOwner = 1, // will translate into "JAVASCRIPT" when published to the OMID JS service.
    OMIDNativeOwner = 2, // will translate into "NATIVE" when published to the OMID JS service.
    OMIDNoneOwner = 3 // will translate into "NONE" when published to the OMID JS service.
};


/*!
 * @abstract List of supported creative types
 */
typedef NS_ENUM(NSUInteger, OMIDCreativeType) {
    // Creative type will be set by JavaScript session script.
    // Integrations must also pass Owner.JAVASCRIPT for impressionOwner.
    OMIDCreativeTypeDefinedByJavaScript = 1,
    // Remaining values set creative type in native layer.
    OMIDCreativeTypeHtmlDisplay = 2,
    OMIDCreativeTypeNativeDisplay = 3,
    OMIDCreativeTypeVideo = 4,
    OMIDCreativeTypeAudio = 5
};

/*!
 *@abstract List of supported impression types
 */
typedef NS_ENUM(NSUInteger, OMIDImpressionType) {
  // ImpressionType will be set by JavaScript session script.
  // Integrations must also pass Owner.JAVASCRIPT for impressionOwner.
  OMIDImpressionTypeDefinedByJavaScript = 1,
  // Remaining values set ImpressionType in native layer.
  OMIDImpressionTypeUnspecified = 2,
  OMIDImpressionTypeLoaded = 3,
  OMIDImpressionTypeBeginToRender = 4,
  OMIDImpressionTypeOnePixel = 5,
  OMIDImpressionTypeViewable = 6,
  OMIDImpressionTypeAudible = 7,
  OMIDImpressionTypeOther = 8
};

@interface OMIDAdSessionConfiguration : NSObject

@property OMIDCreativeType creativeType;
@property OMIDImpressionType impressionType;
@property OMIDOwner impressionOwner;
@property OMIDOwner mediaEventsOwner;
@property BOOL isolateVerificationScripts;

- (nullable instancetype)initWithCreativeType:(OMIDCreativeType)creativeType
                               impressionType:(OMIDImpressionType)impressionType
                              impressionOwner:(OMIDOwner)impressionOwner
                             mediaEventsOwner:(OMIDOwner)mediaEventsOwner
                   isolateVerificationScripts:(BOOL)isolateVerificationScripts
                                        error:(NSError *_Nullable *_Nullable)error;

#pragma mark - Deprecated Methods

/// Returns nil and sets error if OMID isn't active or arguments are invalid.
/// @param impressionOwner providing details of who is responsible for triggering the impression event.
/// @param videoEventsOwner providing details of who is responsible for triggering video events. This is only required for video ad sessions and should be set to videoEventsOwner:OMIDNoneOwner for display ad sessions.
/// @param isolateVerificationScripts determines whether verification scripts will be placed in a sandboxed environment. This will not have any effect for native sessions.

// Note: Planned to be deprecated in OM SDK 1.3.2.

- (nullable instancetype)initWithImpressionOwner:(OMIDOwner)impressionOwner
                                videoEventsOwner:(OMIDOwner)videoEventsOwner
                      isolateVerificationScripts:(BOOL)isolateVerificationScripts
                                           error:(NSError *_Nullable *_Nullable)error;

- (nullable instancetype)initWithImpressionOwner:(OMIDOwner)impressionOwner
                                videoEventsOwner:(OMIDOwner)videoEventsOwner
                                           error:(NSError *_Nullable *_Nullable)error __deprecated_msg("Use -initWithImpressionOwner:videoEventsOwner:isolateVerificationScripts:error: instead.");

@end


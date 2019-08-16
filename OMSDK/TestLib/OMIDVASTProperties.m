//
//  OMIDVASTProperties.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/06/2017.
//

#import "OMIDVASTProperties.h"
#import "OMIDConstants.h"

@implementation OMIDVASTProperties

- (nonnull instancetype)initWithSkipOffset:(CGFloat)skipOffset
                                  autoPlay:(BOOL)autoPlay
                                  position:(OMIDPosition)position {
    return [self initWithSkippable:YES skipOffset:skipOffset autoPlay:autoPlay position:position];
}

- (nonnull instancetype)initWithAutoPlay:(BOOL)autoPlay
                                position:(OMIDPosition)position {
    return [self initWithSkippable:NO skipOffset:0 autoPlay:autoPlay position:position];
}

- (nonnull instancetype)initWithSkippable:(BOOL)skippable
                               skipOffset:(CGFloat)skipOffset
                                 autoPlay:(BOOL)autoPlay
                                 position:(OMIDPosition)position {
    self = [super init];
    if (self) {
        _skippable = skippable;
        _skipOffset = skipOffset;
        _autoPlay = autoPlay;
        _position = position;
    }
    return self;
}

- (NSDictionary *)toJSON {
    return (_skippable)
           ? @{VAST_SKIPPABLE : @(_skippable), VAST_SKIPOFFSET : @(_skipOffset), VAST_AUTOPLAY : @(_autoPlay), VAST_POSITION : [self positionString]}
           : @{VAST_SKIPPABLE : @(_skippable), VAST_AUTOPLAY : @(_autoPlay), VAST_POSITION : [self positionString]};
}

- (NSString *)positionString {
    switch (_position) {
        case OMIDPositionPreroll:
            return VAST_POSITION_PREROLL;

        case OMIDPositionMidroll:
            return VAST_POSITION_MIDROLL;

        case OMIDPositionPostroll:
            return VAST_POSITION_POSTROLL;

        case OMIDPositionStandalone:
            return VAST_POSITION_STANDALONE;
    }
}

@end

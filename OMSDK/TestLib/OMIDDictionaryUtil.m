//
//  NSDictionary+Omid.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 06/08/15.
//

#import "OMIDDictionaryUtil.h"
#import "OMIDConstants.h"

@implementation OMIDDictionaryUtil

+ (NSMutableDictionary *)stateWithFrame:(CGRect)frame clipsToBounds:(BOOL)clipsToBounds {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(frame.origin.x) forKey:STATE_X];
    [dict setObject:@(frame.origin.y) forKey:STATE_Y];
    [dict setObject:@(frame.size.width) forKey:STATE_WIDTH];
    [dict setObject:@(frame.size.height) forKey:STATE_HEIGHT];
    [dict setObject:@(clipsToBounds) forKey:STATE_CLIPS_TO_BOUNDS];
    return dict;
}

+ (void)state:(NSMutableDictionary *)state addObstructionInfo:(OMIDObstructionInfo *)obstructionInfo {
    NSArray<NSString *> *sessionIds = [obstructionInfo.sessionIds sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    OMIDFriendlyObstruction *friendlyObstruction = obstructionInfo.friendlyObstruction;
    [state setObject:sessionIds forKey:STATE_IS_FRIENDLY_OBSTRUCTION_FOR];
    [state setObject:friendlyObstruction.obstructionViewClass forKey:STATE_FRIENDLY_OBSTRUCTION_CLASS];
    [state setObject:[self stringFromObstructionType:friendlyObstruction.purpose] forKey:STATE_FRIENDLY_OBSTRUCTION_PURPOSE];
    if (friendlyObstruction.detailedReason != nil) {
        [state setObject:friendlyObstruction.detailedReason forKey:STATE_FRIENDLY_OBSTRUCTION_REASON];
    }
}

+ (void)state:(NSMutableDictionary *)state addSessionId:(NSString *)sessionId {
    [state setObject:sessionId forKey:STATE_AD_SESSION_ID];
}

+ (void)state:(NSMutableDictionary *)state addChildState:(NSMutableDictionary *)childState {
    NSMutableArray *childViews = [state objectForKey:STATE_CHILDVIEWS];
    if (!childViews) {
        childViews = [NSMutableArray new];
        [state setObject:childViews forKey:STATE_CHILDVIEWS];
    }
    [childViews addObject:childState];
}

+ (BOOL)state:(NSMutableDictionary *)state isEqualToState:(NSMutableDictionary *)anotherState {
    return [state isEqual:anotherState];
}

+ (NSDictionary *)emptyState {
    return [self stateWithFrame:CGRectZero clipsToBounds:YES];
}

+ (NSString *)stringFromJSON:(id)json {
    if (![NSJSONSerialization isValidJSONObject:json]) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    if (!jsonData) {
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)stringFromObstructionType:(OMIDFriendlyObstructionType)obstructionType {
    switch (obstructionType) {
        case OMIDFriendlyObstructionMediaControls:
            return FRIENDLY_OBSTRUCTION_TYPE_MEDIA_CONTROLS;
        case OMIDFriendlyObstructionCloseAd:
            return FRIENDLY_OBSTRUCTION_TYPE_CLOSE_AD;
        case OMIDFriendlyObstructionNotVisible:
            return FRIENDLY_OBSTRUCTION_TYPE_NOT_VISIBLE;
        case OMIDFriendlyObstructionOther:
            return FRIENDLY_OBSTRUCTION_TYPE_OTHER;
    }
}

@end

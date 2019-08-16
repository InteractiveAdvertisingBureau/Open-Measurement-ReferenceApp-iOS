//
//  OMIDViewKey.m
//  AppVerificationLibrary
//
//  Created by Daria on 15/03/17.
//

#import "OMIDViewKey.h"

@implementation OMIDViewKey

+ (nonnull instancetype)viewKeyWithView:(UIView *)view {
    OMIDViewKey *viewKey = [OMIDViewKey new];
    viewKey.view = view;
    return viewKey;
}

- (NSUInteger)hash {
    return _view.hash;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[OMIDViewKey class]]) {
        return NO;
    }
    return _view == [object view];
}

- (id)copyWithZone:(NSZone *)zone {
    OMIDViewKey *omidViewKey = [OMIDViewKey new];
    omidViewKey.view = _view;
    return omidViewKey;
}

@end

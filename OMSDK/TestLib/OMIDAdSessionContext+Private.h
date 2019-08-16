//
//  OMIDAdSessionContext+Private.h
//  AppVerificationLibrary
//
//  Created by Daria on 21/06/2017.
//

#import "OMIDAdSessionContext.h"
#import "OMIDConstants.h"

@interface OMIDAdSessionContext ()

@property(nonatomic, readonly) OMIDAdSessionType type;
@property(nonatomic, readonly) UIView *webView;
@property(nonatomic, readonly) NSArray *resources;
@property(nonatomic, readonly) NSString *script;
@property(nonatomic, readonly) OMIDPartner *partner;
@property(nonatomic, readonly) NSString *contentUrl;
@property(nonatomic, readonly) NSString *identifier;

- (NSDictionary *)toJSON;
- (NSDictionary *)resourcesJSON;

@end

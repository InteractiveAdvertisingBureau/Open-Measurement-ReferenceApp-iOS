//
// Created by Daria Sukhonosova on 19/04/16.
//

#import <WebKit/WebKit.h>
#import "OMIDAdSessionContext+Private.h"
#import "OMIDConstants.h"
#import "OMIDSDK.h"
#import "OMIDContext.h"
#import "OMIDDevice.h"
#import "OMIDPartner+Private.h"
#import "OMIDVerificationScriptResource+Private.h"
#import "OMIDError.h"

@implementation OMIDAdSessionContext

- (nullable instancetype)initWithPartner:(nonnull OMIDPartner *)partner
                                 webView:(nonnull UIView *)webView
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error {
  return [self initWithPartner:partner
                       webView:webView
                    contentUrl:nil
     customReferenceIdentifier:customReferenceIdentifier
                         error:error];
}

- (nullable instancetype)initWithPartner:(nonnull OMIDPartner *)partner
                                 webView:(nonnull UIView *)webView
                              contentUrl:(nullable NSString *)contentUrl
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error {
    self = [super init];
    if (self) {
        if (!OMIDSDK.sharedInstance.isActive) {
            [OMIDError setOMIDErrorFor:error code:OMIDSDKNotActivatedError message:OMID_NOT_ACTIVATED_ERROR_MESSAGE];
            return nil;
        }
        if (![webView isKindOfClass:[UIWebView class]] && ![webView isKindOfClass:[WKWebView class]]) {
            [OMIDError setOMIDErrorFor:error code:OMIDWrongWebViewClassOrNilError message:OMID_WEB_VIEW_SHOULD_BE_UIWEBVIEW_OR_WKWEBVIEW_ERROR_MESSAGE];
            return nil;
        }
        if (!partner) {
            [OMIDError setOMIDErrorFor:error code:OMIDPartnerIsNilError message:OMID_PARTNER_CAN_NOT_BE_NIL_ERROR_MESSAGE];
            return nil;
        }
        if ([customReferenceIdentifier length] > 256) {
            [OMIDError setOMIDErrorFor:error code:OMIDWrongCustomReferenceIdentifierError message:[NSString stringWithFormat:OMID_WRONG_CUSTOM_REFERENCE_IDENTIFIER_ERROR_MESSAGE, (long)[customReferenceIdentifier length]]];
            return nil;
        }
        _partner = partner;
        _webView = webView;
        _type = OMIDAdSessionTypeHTML;
        _contentUrl = [contentUrl copy];
        _identifier = [customReferenceIdentifier copy];
    }
    return self;
}

- (nullable instancetype)initWithPartner:(nonnull OMIDPartner *)partner
                                  script:(nonnull NSString *)script
                               resources:(nonnull NSArray<OMIDVerificationScriptResource *> *)resources
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error {
  return [self initWithPartner:partner
                        script:script
                     resources:resources
                    contentUrl:nil
     customReferenceIdentifier:customReferenceIdentifier
                         error:error];
}

- (nullable instancetype)initWithPartner:(nonnull OMIDPartner *)partner
                                  script:(nonnull NSString *)script
                               resources:(nonnull NSArray<OMIDVerificationScriptResource *> *)resources
                              contentUrl:(nullable NSString *)contentUrl
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error {
    self = [super init];
    if (self) {
        if (!OMIDSDK.sharedInstance.isActive) {
            [OMIDError setOMIDErrorFor:error code:OMIDSDKNotActivatedError message:OMID_NOT_ACTIVATED_ERROR_MESSAGE];
            return nil;
        }
        if (resources.count == 0) {
            [OMIDError setOMIDErrorFor:error code:OMIDResourcesAreEmptyOrNilError message:OMID_RESOURCES_CAN_NOT_BE_EMPTY_ERROR_MESSAGE];
            return nil;
        }
        if (!partner) {
            [OMIDError setOMIDErrorFor:error code:OMIDPartnerIsNilError message:OMID_PARTNER_CAN_NOT_BE_NIL_ERROR_MESSAGE];
            return nil;
        }
        if ([script isEqual:@""]) {
            [OMIDError setOMIDErrorFor:error code:OMIDScriptIsEmptyError message:OMID_SCRIPT_IS_EMPTY_ERROR_MESSAGE];
            return nil;
        }
        if ([customReferenceIdentifier length] > 256) {
            [OMIDError setOMIDErrorFor:error code:OMIDWrongCustomReferenceIdentifierError message:[NSString stringWithFormat:OMID_WRONG_CUSTOM_REFERENCE_IDENTIFIER_ERROR_MESSAGE, (long)[customReferenceIdentifier length]]];
            return nil;
        }
        _partner = partner;
        _resources = [resources copy];
        _type = OMIDAdSessionTypeNative;
        _script = [script copy];
        _contentUrl = [contentUrl copy];
        _identifier = [customReferenceIdentifier copy];
    }
    return self;
}

- (nullable instancetype)initWithPartner:(nonnull OMIDPartner *)partner
                       javaScriptWebView:(nonnull UIView *)webView
                              contentUrl:(nullable NSString *)contentUrl
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error {
    self = [super init];
    if (self) {
        if (!OMIDSDK.sharedInstance.isActive) {
            [OMIDError setOMIDErrorFor:error code:OMIDSDKNotActivatedError message:OMID_NOT_ACTIVATED_ERROR_MESSAGE];
            return nil;
        }
        if (![webView isKindOfClass:[UIWebView class]] && ![webView isKindOfClass:[WKWebView class]]) {
            [OMIDError setOMIDErrorFor:error code:OMIDWrongWebViewClassOrNilError message:OMID_WEB_VIEW_SHOULD_BE_UIWEBVIEW_OR_WKWEBVIEW_ERROR_MESSAGE];
            return nil;
        }
        if (!partner) {
            [OMIDError setOMIDErrorFor:error code:OMIDPartnerIsNilError message:OMID_PARTNER_CAN_NOT_BE_NIL_ERROR_MESSAGE];
            return nil;
        }
        if ([customReferenceIdentifier length] > 256) {
            [OMIDError setOMIDErrorFor:error code:OMIDWrongCustomReferenceIdentifierError message:[NSString stringWithFormat:OMID_WRONG_CUSTOM_REFERENCE_IDENTIFIER_ERROR_MESSAGE, (long)[customReferenceIdentifier length]]];
            return nil;
        }
        _partner = partner;
        _webView = webView;
        _type = OMIDAdSessionTypeJavaScript;
        _contentUrl = [contentUrl copy];
        _identifier = [customReferenceIdentifier copy];
    }
    return self;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *result = [NSMutableDictionary new];
    [result setObject:ENVIROMENT_APP forKey:CONTEXT_ENVIROMENT];
    [result setObject:[self typeString] forKey:CONTEXT_AD_SESSION_TYPE];
    [result setObject:@[FEATURE_CLID, FEATURE_VLID] forKey:CONTEXT_SUPPORTS];
    [result setObject:[_partner toJSON] forKey:CONTEXT_OMID_NATIVE_INFO];
    [result setObject:[OMIDContext.sharedContext toJSON] forKey:CONTEXT_APP];
    [result setObject:[OMIDDevice toJSON] forKey:CONTEXT_DEVICE_INFO];

    if (_contentUrl != nil) {
        [result setObject:_contentUrl forKey:CONTEXT_CONTENT_URL];
    }

    if (_identifier != nil) {
        [result setObject:_identifier forKey:CONTEXT_CUSTOM_REFERENCE_DATA];
    }
    
    return result;
}

- (NSDictionary *)resourcesJSON {
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary new];
    for (OMIDVerificationScriptResource *resource in _resources) {
        if (resource.parameters) {
            [jsonDictionary setObject:resource.parameters forKey:resource.vendorKey];
        }
    }
    return jsonDictionary;
}

- (NSString *)typeString {
    switch (self.type) {
        case OMIDAdSessionTypeHTML:
            return AD_SESSION_HTML;

        case OMIDAdSessionTypeNative:
            return AD_SESSION_NATIVE;
        
        case OMIDAdSessionTypeJavaScript:
            return AD_SESSION_JAVASCRIPT;
    }
}

@end

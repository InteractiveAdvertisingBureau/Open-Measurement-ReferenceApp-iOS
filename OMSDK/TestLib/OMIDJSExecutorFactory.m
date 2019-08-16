//
//  OMIDJSExecutorFactory.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 23/06/2017.
//

#import "OMIDJSExecutorFactory.h"
#import "OMIDUIWebViewJSExecutor.h"
#import "OMIDWKWebViewJSExecutor.h"
#import "OMIDLightJSExecutor.h"
#import "OMIDAdSessionContext+Private.h"

@implementation OMIDJSExecutorFactory

+ (id<OMIDJSExecutor>)JSExecutorForContext:(OMIDAdSessionContext *)context {
    switch (context.type) {
        case OMIDAdSessionTypeHTML:
            return [self JSExecutorWithWebView:context.webView];
            
        case OMIDAdSessionTypeNative:
            return [self JSExecutorWithResources:context.resources script:context.script];
        
        case OMIDAdSessionTypeJavaScript:
            return [self JSExecutorWithWebView:context.webView];
    }
}

+ (id<OMIDJSExecutor>)JSExecutorWithWebView:(UIView *)webView {
    if ([webView isKindOfClass:[UIWebView class]]) {
        return [[OMIDUIWebViewJSExecutor alloc] initWithWebView:(UIWebView *)webView];
    } else if ([webView isKindOfClass:[WKWebView class]]) {
        return [[OMIDWKWebViewJSExecutor alloc] initWithWebView:(WKWebView *)webView];
    }
    return nil;
}

+ (id<OMIDJSExecutor>)JSExecutorWithResources:(NSArray *)resources script:(nonnull NSString *)script {
    OMIDLightJSExecutor *jsExecutor = [OMIDLightJSExecutor lightJSExecutor];
    [jsExecutor injectJavaScriptFromString:script];
    for (OMIDVerificationScriptResource *resource in resources) {
        [jsExecutor.networkBridge injectJavaScriptFromURL:resource.URL];
    }
    return jsExecutor;
}

@end

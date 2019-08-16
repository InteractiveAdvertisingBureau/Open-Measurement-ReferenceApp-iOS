//
// Created by Daria on 31/08/16.
//

#import "OMIDWKWebViewJSExecutor.h"

@interface OMIDWKWebViewJSExecutor () {
    __weak WKWebView *_webView;
}

@end

@implementation OMIDWKWebViewJSExecutor

- (instancetype)initWithWebView:(WKWebView *)webView {
    self = [super init];
    if (self) {
        _webView = webView;
    }
    return self;
}

- (BOOL)supportBackgroundThread {
    return NO;
}

- (id)jsEnvironment {
    return _webView;
}

- (void)injectJavaScriptFromString:(NSString *)script {
    [_webView evaluateJavaScript:script completionHandler:nil];
}

@end

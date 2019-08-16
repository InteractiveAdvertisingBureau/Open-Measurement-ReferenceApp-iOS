//
// Created by Daria on 31/08/16.
//

#import "OMIDUIWebViewJSExecutor.h"

@interface OMIDUIWebViewJSExecutor () {
    __weak UIWebView *_webView;
}

@end

@implementation OMIDUIWebViewJSExecutor

- (instancetype)initWithWebView:(UIWebView *)webView {
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
    [_webView stringByEvaluatingJavaScriptFromString:script];
}

@end

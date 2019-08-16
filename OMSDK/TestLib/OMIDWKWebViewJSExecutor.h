//
// Created by Daria on 31/08/16.
//

#import <WebKit/WebKit.h>
#import "OMIDJSExecutor.h"

/*!
 * @discussion OMIDJSExecutor implementation for WKWebView.
 */
@interface OMIDWKWebViewJSExecutor : NSObject <OMIDJSExecutor>

/*!
 * @abstract Initializes new instance with provided WKWebView.
 *
 * @param webView The web view used ad java script environment.
 * @return New OMIDWKWebViewJSExecutor instance.
 */
- (instancetype)initWithWebView:(WKWebView *)webView;

@end

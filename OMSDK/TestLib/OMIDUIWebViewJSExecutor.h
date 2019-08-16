//
// Created by Daria on 31/08/16.
//

#import <UIKit/UIKit.h>
#import "OMIDJSExecutor.h"

/*!
 * @discussion OMIDJSExecutor implementation for UIWebView.
 */
@interface OMIDUIWebViewJSExecutor : NSObject <OMIDJSExecutor>

/*!
 * @abstract Initializes new instance with provided UIWebView.
 *
 * @param webView The web view used ad java script environment.
 * @return New OMIDUIWebViewJSExecutor instance.
 */
- (instancetype)initWithWebView:(UIWebView *)webView;

@end

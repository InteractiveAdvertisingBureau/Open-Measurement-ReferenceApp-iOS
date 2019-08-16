//
//  OMIDJSNetworkBridge.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 25/07/2017.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "OMIDJSInvoker.h"

typedef enum OMIDDownloadJavaScriptResourceError : NSUInteger {
    OMIDNoInternetConnection,
    OMIDServerUnavailable,
    OMIDResourceNotFound,
    OMIDGenericError
} OMIDDownloadJavaScriptResourceError;

/*!
 * @discussion Native implementation of JS network functions.
 */
@interface OMIDJSNetworkBridge : NSObject

/*!
 * @abstract OMIDJSInvoker used to invoke timer callbacks.
 */
@property(nonatomic, weak) id<OMIDJSInvoker> jsInvoker;

/*!
 * @abstract Injects network bridge methods for provided JS object.
 *
 * @param jsObject The JS object to inject bridge methods.
 */
- (void)setupMethodsForJSObject:(JSValue *)jsObject;

/*!
 * @abstract Downloads java script and injects it to JSContext.
 *
 * @param url The java script URL.
 */
- (void)injectJavaScriptFromURL:(NSURL *)url;

/*!
 * @abstract Sends request to provided URL.
 *
 * @param url The URL.
 * @param successCallback The JSValue containing JS function called if request is successful.
 * @param failureCallback The JSValue containing JS function called if request fails.
 */
- (void)sendURL:(NSURL *)url successCallback:(JSValue *)successCallback failureCallback:(JSValue *)failureCallback;

/*!
 * @abstract Checks if domains dictionary contains guid for url domain and try to download script from url.
 *
 * @param url is URL.
 * @param successCallback The JSValue containing JS function called if request is successful.
 * @param failureCallback The JSValue containing JS function called if request fails.
 */
- (void)downloadJavaScriptResourceWithURL:(NSURL *)url successCallback:(JSValue *)successCallback failureCallback:(JSValue *)failureCallback;

@end

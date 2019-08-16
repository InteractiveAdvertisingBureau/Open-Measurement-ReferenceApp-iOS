//
//  OMIDJSNetworkBridge.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 25/07/2017.
//

#import "OMIDJSNetworkBridge.h"
#import "OMIDLoadTask.h"

#define SEND_URL @"sendUrl"
#define DOWNLOAD_JAVASCRIPT_RESOURCE @"downloadJavaScriptResource"
#define BOOTSTRAP_TEMPLATE @"(function() { %@ }).call(this);"

@implementation OMIDJSNetworkBridge

- (void)setupMethodsForJSObject:(JSValue *)jsObject {
    __weak typeof(self) weakSelf = self;
    jsObject[SEND_URL] = ^(JSValue *urlValue, JSValue *successCallback, JSValue *failureCallback) {
        typeof(weakSelf) strongSelf = weakSelf;
        NSURL *url = [NSURL URLWithString:[urlValue toString]];
        [strongSelf sendURL:url successCallback:successCallback failureCallback:failureCallback];
    };
    jsObject[DOWNLOAD_JAVASCRIPT_RESOURCE] = ^(JSValue *urlValue, JSValue *successCallback, JSValue *failureCallback) {
        typeof(weakSelf) strongSelf = weakSelf;
        NSURL *url = [NSURL URLWithString:[urlValue toString]];
        [strongSelf downloadJavaScriptResourceWithURL:url successCallback:successCallback failureCallback:failureCallback];
    };
}

- (void)downloadJavaScriptResourceWithURL:(NSURL *)url successCallback:(JSValue *)successCallback failureCallback:(JSValue *)failureCallback {
    if (!url) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    OMIDLoadTask *loadTask = [OMIDLoadTask taskToLoadStringFromURL:url attemptsCount:1 completionQueue:self.jsInvoker.dispatchQueue completionHandler:^(id response, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            OMIDDownloadJavaScriptResourceError argument = [self getOMIDError:error];
            [strongSelf.jsInvoker invokeCallback:failureCallback argument:[NSNumber numberWithUnsignedInteger:argument]];
        } else {
            [strongSelf.jsInvoker invokeCallback:successCallback argument:response];
        }
    }];
    [loadTask start];
}

- (void)sendURL:(NSURL *)url successCallback:(JSValue *)successCallback failureCallback:(JSValue *)failureCallback {
    if (!url) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    OMIDLoadTask *task = [OMIDLoadTask taskToSendPingToURL:url completionQueue:self.jsInvoker.dispatchQueue completionHandler:^(id response, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf.jsInvoker invokeCallback:failureCallback];
        } else {
            [strongSelf.jsInvoker invokeCallback:successCallback];
        }
    }];
    [task start];
}

- (void)injectJavaScriptFromURL:(NSURL *)url {
    if (!url) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    OMIDLoadTask *loadTask = [OMIDLoadTask taskToLoadStringFromURL:url attemptsCount:1 completionQueue:self.jsInvoker.dispatchQueue completionHandler:^(id response, NSError *error) {
        typeof(weakSelf)strongSelf = weakSelf;
        if (!error) {            
            [strongSelf.jsInvoker invokeScript: [NSString stringWithFormat:BOOTSTRAP_TEMPLATE, response]];
        }
    }];
    [loadTask start];
}

- (OMIDDownloadJavaScriptResourceError)getOMIDError:(NSError *)error {
    switch (error.code) {
        case NSURLErrorNotConnectedToInternet:
            return OMIDNoInternetConnection;
            break;
        case NSURLErrorResourceUnavailable:
            return OMIDServerUnavailable;
            break;
        case NSNotFound:
            return OMIDResourceNotFound;
            break;
        default:
            return OMIDGenericError;
            break;
    }
}

@end

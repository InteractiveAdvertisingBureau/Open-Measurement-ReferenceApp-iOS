//
//  OMIDBridge.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 31/08/15.
//

#import <Foundation/Foundation.h>
#import "OMIDBridge.h"
#import "OMIDMethodInvoker.h"
#import "OMIDDictionaryUtil.h"
#import "OMIDCommand.h"
#import "OMIDConstants.h"
#import "OMIDAdSession.h"

@implementation OMIDBridge

- (instancetype)initWithJSExecutor:(id<OMIDJSExecutor>)jsExecutor {
    self = [super init];
    if (self) {
        _jsExecutor = jsExecutor;
    }
    return self;
}

- (void)publishCommand:(NSString *)command {
    if (_jsExecutor.supportBackgroundThread) {
        [self internal_publishCommand:command];
    } else {
        [OMIDMethodInvoker performSelectorAsync:@selector(internal_publishCommand:)
                                         target:self
                                       argument:command];
    }
}

- (void)internal_publishCommand:(NSString *)command {
    [_jsExecutor injectJavaScriptFromString:command];
}

- (void)publishInitWithConfiguration:(OMIDAdSessionConfiguration *)configuration {
    NSString *command;
    if (configuration.creativeType && configuration.impressionType) {
        command = [OMIDCommand commandWithName:INIT_SESSION,
                   [OMIDDictionaryUtil stringFromJSON:@{
                                                        IMPRESSION_OWNER: [self getStringOwner:configuration.impressionOwner],
                                                        CREATIVE_TYPE: [self getStringCreativeType:configuration.creativeType],
                                                        IMPRESSION_TYPE: [self getStringImpressionType:configuration.impressionType],
                                                        MEDIA_EVENTS_OWNER: [self getStringOwner:configuration.mediaEventsOwner],
                                                        ISOLATE_VERIFICATION_SCRIPTS: @(configuration.isolateVerificationScripts)}], nil];
        
    } else {
        command = [OMIDCommand commandWithName:INIT_SESSION,
                   [OMIDDictionaryUtil stringFromJSON:@{
                                                        IMPRESSION_OWNER: [self getStringOwner:configuration.impressionOwner],
                                                        VIDEO_EVENTS_OWNER: [self getStringOwner:configuration.mediaEventsOwner],
                                                        ISOLATE_VERIFICATION_SCRIPTS: @(configuration.isolateVerificationScripts)}], nil];
    }
    [self publishCommand:command];
}

- (void)publishStartEventWithAdSessionId:(NSString *)adSessionId
                             JSONContext:(NSDictionary *)context
                  verificationParameters:(NSDictionary *)verificationParameters {
    NSString *identifier = [OMIDCommand stringWithQuotesFromString:adSessionId];
    NSString *contextString = [OMIDDictionaryUtil stringFromJSON:context];
    NSString *verificationParametersString =
        verificationParameters ? [OMIDDictionaryUtil stringFromJSON:verificationParameters] : nil;
    NSString *command;
    if (contextString == nil) {
        NSString *errorMessage = @"Bad context for OMID start event";
        command = [OMIDCommand errorCommandWithType:OMIDErrorGeneric errorMessage:errorMessage];
    } else if (verificationParameters) {
        if (verificationParametersString == nil) {
            NSString *errorMessage = @"Bad verification parameters for OMID start event";
            command = [OMIDCommand errorCommandWithType:OMIDErrorGeneric errorMessage:errorMessage];
        } else {
            command = [OMIDCommand commandWithName:START_SESSION, identifier, contextString,
                verificationParametersString, nil];
        }
    } else {
        command =  [OMIDCommand commandWithName:START_SESSION, identifier, contextString, nil];
    }
    [self publishCommand:command];
}

- (void)publishErrorWithType:(OMIDErrorType)type errorMessage:(NSString *)message {
    NSString *command = [OMIDCommand errorCommandWithType:type errorMessage:message];
    [self publishCommand:command];
}

- (void)publishFinishEvent {
    NSString *command = [OMIDCommand commandWithName:FINISH_SESSION, nil];
    [self publishCommand:command];
}

- (void)publishImpressionEvent {
    NSString *command = [OMIDCommand commandWithName:PUBLISH_IMPRESSION_EVENT, nil];
    [self publishCommand:command];
}

- (void)publishLoadedEvent {
  NSString *command = [OMIDCommand commandWithName:PUBLISH_LOADED_EVENT, nil];
  [self publishCommand:command];
}

- (void)publishLoadedEventWithVastProperties:(OMIDVASTProperties *_Nonnull)vastProperties {
  NSString *command = [OMIDCommand commandWithName:PUBLISH_LOADED_EVENT, [OMIDDictionaryUtil stringFromJSON:[vastProperties toJSON]], nil];
  [self publishCommand:command];
}

- (void)publishMediaEventWithName:(NSString *)name parameters:(NSDictionary *)parameters {
    [self publishEventWithName:name parameters:parameters commandName:PUBLISH_MEDIA_EVENT];
}

- (void)publishEventWithName:(NSString *)name
                  parameters:(NSDictionary *)parameters
                 commandName:(NSString *)commandName {
    NSString *eventName = [OMIDCommand stringWithQuotesFromString:name];
    NSString *command;
    if (parameters) {
        NSString *parameterString = [OMIDDictionaryUtil stringFromJSON:parameters];
        if (parameterString) {
            command = [OMIDCommand commandWithName:commandName, eventName, parameterString, nil];
        } else {
            NSString *errorMessage =
                [NSString stringWithFormat:@"Bad parameters for '%@' event", name];
            command = [OMIDCommand errorCommandWithType:OMIDErrorGeneric errorMessage:errorMessage];
        }
    } else {
        command = [OMIDCommand commandWithName:commandName, eventName, nil];
    }
    [self publishCommand:command];
}

// TODO: Rename OMIDErrorMedia value to MEDIA once JS Service and verification scripts are compliant.
- (NSString *)getStringError:(OMIDErrorType)type {
    switch (type) {
        case OMIDErrorMedia:
            return @"video";
        default:
            return @"generic";
    }
}

- (NSString *)getStringOwner:(OMIDOwner)owner {
    switch (owner) {
        case OMIDJavaScriptOwner:
            return @"javascript";
        case OMIDNativeOwner:
            return @"native";
        case OMIDNoneOwner:
        default:
            return @"none";
    }
}

- (NSString *)getStringCreativeType:(OMIDCreativeType)creativeType {
    switch (creativeType) {
        case OMIDCreativeTypeDefinedByJavaScript:
            return @"definedByJavaScript";
            break;
        case OMIDCreativeTypeHtmlDisplay:
            return @"htmlDisplay";
            break;
        case OMIDCreativeTypeNativeDisplay:
            return @"nativeDisplay";
            break;
        case OMIDCreativeTypeVideo:
            return @"video";
            break;
        case OMIDCreativeTypeAudio:
            return @"audio";
            break;
    }
}

- (NSString *)getStringImpressionType:(OMIDImpressionType)impressionType {
  switch (impressionType) {
    case OMIDImpressionTypeDefinedByJavaScript:
      return @"definedByJavaScript";
      break;
    case OMIDImpressionTypeUnspecified:
      return @"unspecified";
      break;
    case OMIDImpressionTypeLoaded:
      return @"loaded";
      break;
    case OMIDImpressionTypeBeginToRender:
      return @"beginToRender";
      break;
    case OMIDImpressionTypeOnePixel:
      return @"onePixel";
      break;
    case OMIDImpressionTypeViewable:
      return @"viewable";
      break;
    case OMIDImpressionTypeAudible:
      return @"audible";
      break;
    case OMIDImpressionTypeOther:
      return @"other";
      break;
  }
}


@end


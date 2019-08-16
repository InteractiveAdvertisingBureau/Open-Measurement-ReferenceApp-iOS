//
//  OMIDInfo.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 13/10/15.
//

#define OMID_JS_URL @"https://mobile-static.adsafeprotected.com/OMID-v2.js"

#define STATE_CHILDVIEWS @"childViews"
#define STATE_X @"x"
#define STATE_Y @"y"
#define STATE_WIDTH @"width"
#define STATE_HEIGHT @"height"
#define STATE_AD_SESSION_ID @"adSessionId"
#define STATE_CLIPS_TO_BOUNDS @"clipsToBounds"
#define STATE_IS_FRIENDLY_OBSTRUCTION_FOR @"isFriendlyObstructionFor"
#define STATE_FRIENDLY_OBSTRUCTION_CLASS @"friendlyObstructionClass"
#define STATE_FRIENDLY_OBSTRUCTION_PURPOSE @"friendlyObstructionPurpose"
#define STATE_FRIENDLY_OBSTRUCTION_REASON @"friendlyObstructionReason"

#define FRIENDLY_OBSTRUCTION_TYPE_MEDIA_CONTROLS @"MEDIA_CONTROLS"
#define FRIENDLY_OBSTRUCTION_TYPE_CLOSE_AD @"CLOSE_AD"
#define FRIENDLY_OBSTRUCTION_TYPE_NOT_VISIBLE @"NOT_VISIBLE"
#define FRIENDLY_OBSTRUCTION_TYPE_OTHER @"OTHER"

#define APP_STATE_FOREGROUNDED @"foregrounded"
#define APP_STATE_BACKGROUNDED @"backgrounded"

#define CONTEXT_ENVIROMENT @"environment"
#define CONTEXT_AD_SESSION_TYPE @"adSessionType"
#define CONTEXT_SUPPORTS @"supports"
#define CONTEXT_OMID_NATIVE_INFO @"omidNativeInfo"
#define CONTEXT_PARTNER_NAME @"partnerName"
#define CONTEXT_PARTNER_VERSION @"partnerVersion"
#define CONTEXT_APP @"app"
#define CONTEXT_APP_ID @"appId"
#define CONTEXT_LIBRARY_VERSION @"libraryVersion"
#define CONTEXT_CONTENT_URL @"contentUrl"
#define CONTEXT_CUSTOM_REFERENCE_DATA @"customReferenceData"
#define CONTEXT_DEVICE_INFO @"deviceInfo"
#define CONTEXT_DEVICE_TYPE @"deviceType"
#define CONTEXT_DEVICE_OS @"os"
#define CONTEXT_DEVICE_OS_VERSION @"osVersion"
#define CONTEXT_NA_VALUE @"n/a"

#define AD_SESSION_HTML @"html"
#define AD_SESSION_NATIVE @"native"
#define AD_SESSION_JAVASCRIPT @"javascript"

#define ENVIROMENT_APP @"app"
#define FEATURE_CLID @"clid"
#define FEATURE_VLID @"vlid"

#define AD_IMPRESSION @"impression"
#define AD_ERROR @"error"
#define AD_ERROR_MESSAGE @"message"

#define IMPRESSION_OWNER @"impressionOwner"
#define VIDEO_EVENTS_OWNER @"videoEventsOwner"
#define MEDIA_EVENTS_OWNER @"mediaEventsOwner"
#define CREATIVE_TYPE @"creativeType"
#define IMPRESSION_TYPE @"impressionType"
#define ISOLATE_VERIFICATION_SCRIPTS @"isolateVerificationScripts"

#define VAST_SKIPPABLE @"skippable"
#define VAST_SKIPOFFSET @"skipOffset"
#define VAST_AUTOPLAY @"autoPlay"
#define VAST_POSITION @"position"

#define VAST_POSITION_PREROLL @"preroll"
#define VAST_POSITION_MIDROLL @"midroll"
#define VAST_POSITION_POSTROLL @"postroll"
#define VAST_POSITION_STANDALONE @"standalone"

#define MEDIA_LOADED @"loaded"
#define MEDIA_START @"start"
#define MEDIA_COMPLETE @"complete"
#define MEDIA_FIRST_QUARTILE @"firstQuartile"
#define MEDIA_MIDPOINT @"midpoint"
#define MEDIA_THIRD_QUARTILE @"thirdQuartile"
#define MEDIA_PAUSE @"pause"
#define MEDIA_RESUME @"resume"
#define MEDIA_SKIPPED @"skipped"
#define MEDIA_BUFFER_START @"bufferStart"
#define MEDIA_BUFFER_FINISH @"bufferFinish"
#define MEDIA_VOLUME_CHANGE @"volumeChange"
#define MEDIA_ERROR @"error"
#define MEDIA_PLAYER_STATE_CHANGE @"playerStateChange"
#define MEDIA_USER_INTERACTION @"adUserInteraction"

#define VIDEO_PLAYER_VOLUME @"videoPlayerVolume"
#define MEDIA_PLAYER_VOLUME @"mediaPlayerVolume"
#define MEDIA_DEVICE_VOLUME @"deviceVolume"
#define MEDIA_DURATION @"duration"
#define MEDIA_ERROR_MESSAGE @"message"
#define MEDIA_PLAYER_STATE @"state"
#define MEDIA_INTERACTION_TYPE @"interactionType"

#define MEDIA_PLAYER_STATE_MINIMIZED @"minimized"
#define MEDIA_PLAYER_STATE_COLLAPSED @"collapsed"
#define MEDIA_PLAYER_STATE_NORMAL @"normal"
#define MEDIA_PLAYER_STATE_EXPANDED @"expanded"
#define MEDIA_PLAYER_STATE_FULLSCREEN @"fullscreen"

#define MEDIA_USER_INTERACTION_CLICK @"click"
#define MEDIA_USER_INTERACTION_ACCEPT_INVITATION @"invitationAccept"

#define OMID_ERROR_DOMAIN @"com.omid.library"
#define OMID_COMPATIBILIY_ERROR_MESSAGE @"OM SDK is not compatible with API version %@. OM SDK version is %@."
#define OMID_NOT_ACTIVATED_ERROR_MESSAGE @"OM SDK has not been activated."
#define OMID_IMPRESSION_OWNER_CAN_NOT_BE_NONE_ERROR_MESSAGE @"Impression owner can not be none."
#define OMID_IMPRESSION_OWNER_SHOULD_BE_NATIVE_ERROR_MESSAGE @"Impression owner should be NATIVE."
#define OMID_MEDIA_OWNER_SHOULD_BE_NATIVE_ERROR_MESSAGE @"Media events owner should be NATIVE."
#define OMID_CONTEXT_CAN_NOT_BE_NIL_ERROR_MESSAGE @"Context can not be nil."
#define OMID_SCRIPT_IS_EMPTY_ERROR_MESSAGE @"Script can not be empty."
#define OMID_EVENT_FILTER_DOES_NOT_ACCEPT_ERROR_MESSAGE @"Event filter does not accept."
#define OMID_WRONG_CUSTOM_REFERENCE_IDENTIFIER_ERROR_MESSAGE @"The supplied customReferenceIdentifier is %ld characters which exceeds the 256 limit."
#define OMID_AD_SESSION_CAN_NOT_BE_NIL_ERROR_MESSAGE @"Ad session can not be nil."
#define OMID_WEB_VIEW_SHOULD_BE_UIWEBVIEW_OR_WKWEBVIEW_ERROR_MESSAGE @"Web view should be UIWebView or WKWebView or not null."
#define OMID_PARTNER_CAN_NOT_BE_NIL_ERROR_MESSAGE @"Partner can not be nil."
#define OMID_RESOURCES_CAN_NOT_BE_EMPTY_ERROR_MESSAGE @"Resources can not be empty."
#define OMID_FRIENDLY_OBSTRUCTION_CAN_NOT_BE_NIL_ERROR_MESSAGE @"Friendly obstruction can not be nil."
#define OMID_FRIENDLY_OBSTRUCTION_REASON_IS_INVALID_ERROR_MESSAGE @"Friendly obstruction has improperly formatted detailed reason."
#define OMID_CREATIVE_TYPE_IS_INVALID_ERROR_MESSAGE @"CreativeType is invalid."
#define OMID_IMPRESSION_TYPE_IS_INVALID_ERROR_MESSAGE @"ImpressionType is invalid"
#define OMID_CREATIVE_TYPE_AND_IMPRESSION_TYPE_SHOULD_BE_JAVASCRIPT_ERROR_MESSAGE @"CreativeType/ImpressionType that is DefinedByJavascript must have a JavaScript impressionOwner."


typedef enum OMIDErrorCode : NSUInteger {
    OMIDCompatibilityError = 1,
    OMIDSDKNotActivatedError = 2,
    OMIDWrongCustomReferenceIdentifierError = 1500,
    OMIDScriptIsEmptyError = 1501,
    OMIDImpressionOwnerIsNoneError = 1502,
    OMIDImpressionOwnerShouldBeNativeError = 1503,
    OMIDMediaEventsOwnerShouldBeNativeError = 1504,
    OMIDEventFilterDoesNotAcceptError = 1505,
    OMIDContextIsNilError = 1506,
    OMIDAdSessionIsNilError = 1507,
    OMIDWrongWebViewClassOrNilError = 1508,
    OMIDPartnerIsNilError = 1509,
    OMIDResourcesAreEmptyOrNilError = 1510,
    OMIDFriendlyObstructionIsNilError = 1511,
    OMIDFriendlyObstructionReasonInvalid = 1512,
    OMIDCreativeTypeIsInvalidError = 1513,
    OMIDImpressionTypeIsInvalidError = 1514,
    OMIDCreativeTypeAndImpressionTypeShouldBothBeJavaScriptError = 1515
} OMIDErrorCode;

typedef enum OMIDAdSessionType : NSUInteger {
    OMIDAdSessionTypeHTML,
    OMIDAdSessionTypeNative,
    OMIDAdSessionTypeJavaScript
} OMIDAdSessionType;

typedef enum OMIDAppState : NSUInteger {
    OMIDAppStateForegrounded,
    OMIDAppStateBackgrounded
} OMIDAppState;

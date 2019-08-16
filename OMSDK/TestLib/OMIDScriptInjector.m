//
//  OMIDScriptInjector.m
//  AppVerificationLibrary
//
//  Created by Daria on 21/06/2017.
//

#import "OMIDScriptInjector.h"
#import "OMIDConstants.h"
#import "OMIDError.h"

#define HEAD_TAG @"head"
#define BODY_TAG @"body"
#define HTML_TAG @"html"

#define TAG_LENGTH 4
#define SELF_CLOSING_TAG @"/>"

#define START_TAG_REGEX @"(<head[^>]*>|<body[^>]*>|<html[^>]*>|<!DOCTYPE[^>]*>)"
#define COMMENT_REGEX @"\\<![ \r\n\t]*(--([^\\-]|[\r\n]|-[^\\-])*--[ \r\n\t]*)\\>"

#define SCRIPT_CONTENT_TEMPLATE @"<script type=\"text/javascript\">%@</script>"
#define SCRIPT_RESOURCE_TEMPLATE @"<script type=\"text/javascript\" src=\"%@\"></script>"

@implementation OMIDScriptInjector

+ (nullable NSString *)injectScriptContent:(nonnull NSString *)scriptContent
                                  intoHTML:(nonnull NSString *)html
                                     error:(NSError *_Nullable *_Nullable)error {

    if ([scriptContent isEqualToString:@""]) {
        [OMIDError setOMIDErrorFor:error code:OMIDScriptIsEmptyError message:OMID_SCRIPT_IS_EMPTY_ERROR_MESSAGE];
        return nil;
    }
    
    NSString *resultScript = [NSString stringWithFormat:SCRIPT_CONTENT_TEMPLATE, scriptContent];
    return [self stringFromHtml:html byInsertingScript:resultScript];
}

+ (NSString *)stringFromHtml:(NSString *)html byInsertingScript:(NSString *)script {
    NSMutableString *temp = [html mutableCopy];
    NSUInteger index = [self indexForScriptInHtml:temp];
    [temp insertString:script atIndex:index];
    return temp;
}

+ (NSUInteger)indexForScriptInHtml:(NSMutableString *)html {
    NSArray *comments = [self commentsInHtml:html];
    __block NSRange headOrBodyRange = NSMakeRange(0, 0);
    __block NSRange htmlRange = NSMakeRange(0, 0);
    __block NSRange doctypeRange = NSMakeRange(0, 0);
    void (^block)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) = ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *tag = [[self tagFromHtml:html inRange:result.range] lowercaseString];
        if ([tag isEqualToString:HEAD_TAG] || [tag isEqualToString:BODY_TAG]) {
            headOrBodyRange = result.range;
            *stop = YES;
        } else if ([tag isEqualToString:HTML_TAG]) {
            htmlRange = result.range;
        } else {
            doctypeRange = result.range;
        }
    };
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:START_TAG_REGEX
                                                       options:NSRegularExpressionCaseInsensitive
                                                         error:NULL];
    NSUInteger start = 0;
    for (NSTextCheckingResult *comment in comments) {
        NSUInteger end = comment.range.location;
        [regex enumerateMatchesInString:html options:0 range:NSMakeRange(start, end - start) usingBlock:block];
        if (headOrBodyRange.length > 0) {
            break;
        }
        start = comment.range.location + comment.range.length;
    }
    NSRange result = doctypeRange;
    if (headOrBodyRange.length > 0) {
        result = [self replaceSelfClosingTagInHtml:html tagRange:headOrBodyRange];
    } else if (htmlRange.length > 0) {
        result = [self replaceSelfClosingTagInHtml:html tagRange:htmlRange];
    }
    return result.location + result.length;
}

+ (NSRange)replaceSelfClosingTagInHtml:(NSMutableString *)html tagRange:(NSRange)tagRange {
    NSRange endRange = NSMakeRange(tagRange.location + tagRange.length - SELF_CLOSING_TAG.length, SELF_CLOSING_TAG.length);
    NSString *end = [html substringWithRange:endRange];
    if (![SELF_CLOSING_TAG isEqualToString:end]) {
        return tagRange;
    }
    NSString *tag = [self tagFromHtml:html inRange:tagRange];
    [html replaceCharactersInRange:endRange withString:[NSString stringWithFormat:@"></%@>", tag]];
    return NSMakeRange(tagRange.location, tagRange.length - 1);
}

+ (NSString *)tagFromHtml:(NSString *)html inRange:(NSRange)range {
    return [html substringWithRange:NSMakeRange(range.location + 1, TAG_LENGTH)];
}

+ (NSArray *)commentsInHtml:(NSString *)html {
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:COMMENT_REGEX
                                                       options:NSRegularExpressionCaseInsensitive
                                                         error:NULL];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[regex matchesInString:html options:0 range:NSMakeRange(0, html.length)]];
    NSRange ranges[1] = {NSMakeRange(html.length, 0)};
    NSTextCheckingResult *result = [NSTextCheckingResult regularExpressionCheckingResultWithRanges:ranges count:1 regularExpression:regex];
    [array addObject:result];
    return array;
}

@end

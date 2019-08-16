//
//  OMIDCommand.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 23/07/15.
//

#import <Foundation/Foundation.h>
#import "OMIDCommand.h"

#define OMID_BRIDGE_COMMAND @"(function(){if(this.omidBridge!==undefined){this.omidBridge.%@(%@)}})()"

@implementation OMIDCommand

+ (NSString *)commandWithName:(NSString *)name,... {
    va_list args;
    va_start(args, name);
    NSString *arguments = [self stringFromArguments:args];
    NSString *command = [NSString stringWithFormat:OMID_BRIDGE_COMMAND, name, arguments];
    va_end(args);
    return command;
}

+ (NSString *)errorCommandWithType:(OMIDErrorType)type errorMessage:(NSString *)message {
    NSString *typeString = [self stringWithQuotesFromString:[self getStringError:type]];
    NSString *messageString = [self escapedString:message];
    return [self commandWithName:ERROR, typeString, messageString, nil];
}

+ (NSString *)stringWithQuotesFromString:(NSString *)string {
    return [NSString stringWithFormat:@"'%@'", string];
}

+ (NSString *)escapedString:(NSString *)string {
    NSMutableString* escaped = [string mutableCopy];
    [escaped replaceOccurrencesOfString:@"\\"
                             withString:@"\\\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"\""
                             withString:@"\\\""
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"\'"
                             withString:@"\\\'"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"\n"
                             withString:@"\\n"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"\r"
                             withString:@"\\r"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, escaped.length)];
    [escaped insertString:@"\'" atIndex:0];
    [escaped appendString:@"\'"];
    return escaped;
}

+ (NSString *)stringFromArguments:(va_list)arguments {
    NSMutableString *buffer = [NSMutableString new];
    NSString *arg;
    while ((arg = va_arg(arguments, NSString *)) != nil) {
        if (buffer.length > 0) {
            [buffer appendString:@","];
        }
        [buffer appendString:arg];
    }
    return buffer;
}

// TODO: Rename OMIDErrorMedia value to MEDIA once JS Service and verification scripts are compliant.
+ (NSString *)getStringError:(OMIDErrorType)type {
    switch (type) {
        case OMIDErrorMedia:
            return @"video";
        case OMIDErrorGeneric:
        default:
            return @"generic";
    }
}

@end

//
//  OMIDCommandPublisher.h
//  AppVerificationLibrary
//
//  Created by Daria on 06/07/2017.
//

#import <Foundation/Foundation.h>

/*!
 * @discussion Provides a capacity to publish any command to JS layer.
 */
@protocol OMIDCommandPublisher <NSObject>

/*!
 * @abstract Publishes command to JS layer.
 *
 * @param command A string which contains the command.
 */
- (void)publishCommand:(NSString *)command;

@end

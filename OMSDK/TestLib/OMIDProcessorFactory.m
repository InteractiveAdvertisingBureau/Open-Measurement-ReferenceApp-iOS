//
//  OMIDProcessorFactory.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/10/15.
//
#import "OMIDScreenProcessor.h"
#import "OMIDWindowProcessor.h"
#import "OMIDViewProcessor.h"
#import "OMIDProcessorFactory.h"

@interface OMIDProcessorFactory () {
    id<OMIDNodeProcessor> _screenProcessor;
    id<OMIDNodeProcessor> _windowProcessor;
    id<OMIDNodeProcessor> _viewProcessor;
}

@end

@implementation OMIDProcessorFactory

- (id)init {
    self = [super init];
    if (self) {
        _viewProcessor = [OMIDViewProcessor new];
        _viewProcessor.processorForChildren = _viewProcessor;
        _windowProcessor = [OMIDWindowProcessor new];
        _windowProcessor.processorForChildren = _viewProcessor;
        _screenProcessor = [OMIDScreenProcessor new];
        _screenProcessor.processorForChildren = _windowProcessor;
    }
    return self;
}

- (id<OMIDNodeProcessor>)rootProcessor {
    return _screenProcessor;
}

@end

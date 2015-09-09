//
//  CustomTransformer.m
//  RACWSEcho
//
//  Created by dimon on 08/09/15.
//
//

#import "RequestMessageTransformer.h"

@implementation RequestMessageTransformer

+ (Class)transformedValueClass { return [NSString class]; }

+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {
    NSLog(@"Transform value with %@",NSStringFromClass([self class]));
    id transformedValue = [value uppercaseString];
    NSLog(@"source --> %@ transformed --> %@",value,transformedValue);
    return transformedValue;
}

@end

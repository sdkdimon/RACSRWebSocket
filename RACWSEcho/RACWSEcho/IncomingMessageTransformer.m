//
//  IncomingMessageTransformer.m
//  RACWSEcho
//
//  Created by dimon on 08/09/15.
//
//

#import "IncomingMessageTransformer.h"

@implementation IncomingMessageTransformer
+ (Class)transformedValueClass { return [NSString class]; }

+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {
    NSLog(@"Transform value with %@",NSStringFromClass([self class]));
    id transformedValue = [value lowercaseString];
    NSLog(@"source --> %@ transformed --> %@",value,transformedValue);
    return transformedValue;
}
@end

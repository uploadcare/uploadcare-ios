//
//  UCSocialObject.m
//  ExampleProject
//
//  Created by Yury Nechaev on 06.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialObject.h"
#import "UCSocialMacroses.h"
#import <ObjC/Runtime.h>

#define MAPPING_DEBUG (0 && DEBUG)

@interface NSObject(Properties)
+ (Class)classOfPropertyNamed:(NSString *)name;
@end

@implementation NSObject(Properties)

+ (Class)classOfPropertyNamed:(NSString *)name
{
    objc_property_t property = class_getProperty( self, [name UTF8String] );
    if ( property == NULL )
        return ( NULL );
    
    return ( property_getClass(property) );
}

Class property_getClass( objc_property_t property )
{
    const char * attrs = property_getAttributes( property );
    if ( attrs == NULL )
        return ( NULL );
    
    static char buffer[256];
    const char * e = strchr( attrs, ',' );
    if ( e == NULL )
        return ( NULL );
    
    int len = (int)(e - attrs);
    memcpy( buffer, attrs, len );
    buffer[len] = '\0';
    
    Class propertyClass = nil;
    NSString *attributes = [NSString stringWithFormat:@"%s" , buffer];
    NSArray *splitPropertyAttributes = [attributes componentsSeparatedByString:@","];
    if (splitPropertyAttributes.count > 0) {
        NSString *encodeType = splitPropertyAttributes[0];
        NSArray *splitEncodeType = [encodeType componentsSeparatedByString:@"\""];
        NSString *className = splitEncodeType[1];
        propertyClass = NSClassFromString(className);
    }

    return propertyClass;
}

@end

@interface UCSocialObject ()

@property (nonatomic, strong) id serializedObject;

@end

@implementation UCSocialObject

+ (NSDictionary *)mapping {
    UCAbstractAssert
    return nil;
}

+ (NSDictionary *)collectionMapping {
    UCAbstractAssert
    return nil;
}

- (id)initWithSerializedObject:(id)object {
    self = [super init];
    if (self) {
        _serializedObject = object;
        [self performMapping];
        [self performCustomMapping];
    }
    return self;
}

- (void)performMapping {
#if MAPPING_DEBUG
    NSLog(@"%@ mapping started", self.description);
#endif
    for (NSString *key in [self class].mapping) {
        NSAssert([self respondsToSelector:NSSelectorFromString(key)], @"Class %@ does not repond for selector %@", NSStringFromClass([self class]), key);
        Class type = [[self class] classOfPropertyNamed:key];
        id value = self.serializedObject[[self class].mapping[key]];

        // collection
        if ([type isSubclassOfClass:[NSArray class]]) {
            NSDictionary *collectionMapping = [[self class] collectionMapping];
            Class socialClass = collectionMapping ? collectionMapping[key] : nil;
            if (socialClass) {
                if ([socialClass isSubclassOfClass:[UCSocialObject class]]) {
                    NSMutableArray *temp = @[].mutableCopy;
                    for (id node in value) {
                        id obj = [[socialClass alloc] initWithSerializedObject:node];
                        [temp addObject:obj];
                    }
                    if (temp.count) [self setValue:temp.copy forKey:key];
                }
            } else {
                [self setValue:value forKey:key];
            }
        } else
        // object mapping
        if ([type isSubclassOfClass:[UCSocialObject class]]) {
            if (![value isKindOfClass:[NSNull class]]) {
                id obj = [[type alloc] initWithSerializedObject:value];
                [self setValue:obj forKey:key];
            }
        } else {
            [self setValue:value forKey:key];
        }
    }
#if MAPPING_DEBUG
    NSLog(@"%@ mapping finished", self.description);
#endif
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if (![value isKindOfClass:[NSNull class]]) {
        [super setValue:value forKey:key];
    }
}

- (void)performCustomMapping {
}

@end

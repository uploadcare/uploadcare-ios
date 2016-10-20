//
//  UIImage+Bundle.m
//  Pods
//
//  Created by Ruslan on 19/10/2016.
//
//

#import "UIImage+Bundle.h"

@implementation UIImage (Bundle)

+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:name.stringByDeletingPathExtension ofType:name.pathExtension ?: @"png"]];
}

@end

//
//  NSURL+UCDN.m
//  ExampleProject
//
//  Created by Yury Nechaev on 16.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "NSURL+UCDN.h"

@implementation NSURL (UCDN)

+ (instancetype)uc_pathWithRoot:(NSString *)root UUID:(NSString *)uuid {
    return [NSURL URLWithString:[NSString uc_pathWithRoot:root UUID:uuid]];
}

+ (instancetype)uc_pathWithUUID:(NSString *)uuid {
    return [NSURL URLWithString:[NSString uc_pathWithUUID:uuid]];
}

- (NSURL *)uc_format:(UCDNFormat)format {
    return [NSURL URLWithString:[[self absoluteString] uc_format:format]];
}

- (NSURL *)uc_quality:(UCDNQuality)quality {
    return [NSURL URLWithString:[[self absoluteString] uc_quality:quality]];
}

- (NSURL *)uc_progressive:(BOOL)progressive {
    return [NSURL URLWithString:[[self absoluteString] uc_progressive:progressive]];
}

- (NSURL *)uc_preview {
    return [NSURL URLWithString:[[self absoluteString] uc_preview]];
}

- (NSURL *)uc_preview:(CGSize)size {
    return [NSURL URLWithString:[[self absoluteString] uc_preview:size]];
}

- (NSURL *)uc_resize:(CGSize)size {
    return [NSURL URLWithString:[[self absoluteString] uc_resize:size]];
}

- (NSURL *)uc_crop:(CGSize)size {
    return [NSURL URLWithString:[[self absoluteString] uc_crop:size]];
}

- (NSURL *)uc_crop:(CGSize)size center:(CGPoint)center {
    return [NSURL URLWithString:[[self absoluteString] uc_crop:size center:center]];
}

- (NSURL *)uc_cropToCenter:(CGSize)size {
    return [NSURL URLWithString:[[self absoluteString] uc_cropToCenter:size]];
}

- (NSURL *)uc_scaleCrop:(CGSize)size {
    return [NSURL URLWithString:[[self absoluteString] uc_scaleCrop:size]];
}

- (NSURL *)uc_scaleCropToCenter:(CGSize)size {
    return [NSURL URLWithString:[[self absoluteString] uc_scaleCropToCenter:size]];
}

- (NSURL *)uc_stretch:(UCDNStretchMode)mode {
    return [NSURL URLWithString:[[self absoluteString] uc_stretch:mode]];
}

- (NSURL *)uc_setFill:(UIColor *)color {
    return [NSURL URLWithString:[[self absoluteString] uc_setFill:color]];
}

- (NSURL *)uc_overlay:(NSString *)uuid
   relativeDimensions:(CGSize)relativeDimensions
  relativeCoordinates:(CGPoint)relativeCoordinates
              opacity:(CGFloat)opacity {
    return [NSURL URLWithString:[[self absoluteString] uc_overlay:uuid relativeDimensions:relativeDimensions relativeCoordinates:relativeCoordinates opacity:opacity]];
}


- (NSURL *)uc_overlay:(NSString *)uuid
   relativeDimensions:(CGSize)relativeDimensions
  relativeCoordinates:(CGPoint)relativeCoordinates {
    return [NSURL URLWithString:[[self absoluteString] uc_overlay:uuid relativeDimensions:relativeDimensions relativeCoordinates:relativeCoordinates]];
}

- (NSURL *)uc_overlayAtCenter:(NSString *)uuid
           relativeDimensions:(CGSize)relativeDimensions
                      opacity:(CGFloat)opacity {
    return [NSURL URLWithString:[[self absoluteString] uc_overlayAtCenter:uuid relativeDimensions:relativeDimensions opacity:opacity]];
}

- (NSURL *)uc_overlayAtCenter:(NSString *)uuid
           relativeDimensions:(CGSize)relativeDimensions {
    return [NSURL URLWithString:[[self absoluteString] uc_overlayAtCenter:uuid relativeDimensions:relativeDimensions]];
}

- (NSURL *)uc_autorotate:(BOOL)autorotate {
    return [NSURL URLWithString:[[self absoluteString] uc_autorotate:autorotate]];
}

- (NSURL *)uc_sharp:(NSUInteger)sharp {
    return [NSURL URLWithString:[[self absoluteString] uc_sharp:sharp]];
}

- (NSURL *)uc_blur:(NSUInteger)blur {
    return [NSURL URLWithString:[[self absoluteString] uc_blur:blur]];
}

- (NSURL *)uc_rotate:(NSUInteger)angle {
    return [NSURL URLWithString:[[self absoluteString] uc_rotate:angle]];
}

- (NSURL *)uc_flip {
    return [NSURL URLWithString:[[self absoluteString] uc_flip]];
}

- (NSURL *)uc_mirror {
    return [NSURL URLWithString:[[self absoluteString] uc_mirror]];
}

- (NSURL *)uc_grayscale {
    return [NSURL URLWithString:[[self absoluteString] uc_grayscale]];
}

- (NSURL *)uc_invert {
    return [NSURL URLWithString:[[self absoluteString] uc_invert]];
}

- (NSURL *)uc_addParameter:(NSString *)parameter {
    return [NSURL URLWithString:[[self absoluteString] uc_addParameter:parameter]];
}

@end

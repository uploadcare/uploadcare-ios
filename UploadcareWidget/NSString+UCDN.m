//
//  NSString+UCDN.m
//  ExampleProject
//
//  Created by Yury Nechaev on 15.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "NSString+UCDN.h"
#import <objc/runtime.h>

static NSString * const UCDNParameterSeparator = @"-";
static NSString * const UCDNRootHost = @"https://ucarecdn.com";


@implementation NSString (UCDN)

#pragma mark - lifecycle

+ (instancetype)uc_pathWithRoot:(NSString *)root UUID:(NSString *)uuid {
    NSParameterAssert(root);
    NSString *path = [[[self class] alloc] initWithString:[root stringByAppendingFormat:@"/%@/",uuid]];
    return path;
}

+ (instancetype)uc_pathWithUUID:(NSString *)uuid {
    NSString *path = [[[self class] alloc] initWithString:[UCDNRootHost stringByAppendingFormat:@"/%@/",uuid]];
    return path;
}

#pragma mark - format

static NSString * const UCDNFormatKey = @"format";
static NSString * const UCDNFormatJpegValue = @"jpeg";
static NSString * const UCDNFormatPngValue = @"png";

- (NSString *)uc_format:(UCDNFormat)format {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%@", UCDNFormatKey, [self formatValueFromFormat:format]]];
}

- (NSString *)formatValueFromFormat:(UCDNFormat)format {
    NSString *returnedValue = nil;
    switch (format) {
        case UCDNFormatJpeg: {
            returnedValue = UCDNFormatJpegValue;
            break;
        }
        case UCDNFormatPng: {
            returnedValue = UCDNFormatPngValue;
            break;
        }
        default: {
            returnedValue = UCDNFormatJpegValue;
            break;
        }
    }
    return returnedValue;
}

#pragma mark - quality

static NSString * const UCDNQualityKey = @"quality";
static NSString * const UCDNQualityLevelNormal = @"normal";
static NSString * const UCDNQualityLevelBetter = @"better";
static NSString * const UCDNQualityLevelBest = @"best";
static NSString * const UCDNQualityLevelLighter = @"lighter";
static NSString * const UCDNQualityLevelLightest = @"lightest";

- (NSString *)uc_quality:(UCDNQuality)quality {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%@", UCDNQualityKey, [self qualityForLevel:quality]]];
}

- (NSString *)qualityForLevel:(UCDNQuality)qualityLevel {
    NSString *returnedValue = UCDNQualityNormal;
    switch (qualityLevel) {
        case UCDNQualityNormal: {
            returnedValue = UCDNQualityNormal;
            break;
        }
        case UCDNQualityBetter: {
            returnedValue = UCDNQualityLevelBetter;

            break;
        }
        case UCDNQualityBest: {
            returnedValue = UCDNQualityLevelBest;

            break;
        }
        case UCDNQualityLighter: {
            returnedValue = UCDNQualityLevelLighter;

            break;
        }
        case UCDNQualityLightest: {
            returnedValue = UCDNQualityLevelLightest;

            break;
        }
    }
    return returnedValue;
}

#pragma mark - progressive

static NSString * const UCDNProgressiveKey = @"progressive";
static NSString * const UCDNProgressiveYes = @"yes";
static NSString * const UCDNProgressiveNo = @"no";


- (NSString *)uc_progressive:(BOOL)progressive {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%@", UCDNProgressiveKey, progressive ? UCDNProgressiveYes : UCDNProgressiveNo]];
}

#pragma mark - preview

static NSString * const UCDNPreviewKey = @"preview";

- (NSString *)uc_preview {
    return [self uc_addParameter:UCDNPreviewKey];
}

- (NSString *)uc_preview:(CGSize)size {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%@", UCDNPreviewKey, [self uc_dimensionsFromSize:size]]];
}

#pragma mark - resize

static NSString * const UCDNResizeKey = @"resize";

- (NSString *)uc_resize:(CGSize)size {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%@", UCDNResizeKey, [self uc_oneOrTwoDimensionsFromSize:size]]];
}

#pragma mark - crop

static NSString * const UCDNCropKey = @"crop";
static NSString * const UCDNCropCenter = @"center";


- (NSString *)uc_crop:(CGSize)size {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%@", UCDNCropKey, [self uc_dimensionsFromSize:size]]];
}

- (NSString *)uc_crop:(CGSize)size center:(CGPoint)center {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%@/%@", UCDNCropKey, [self uc_dimensionsFromSize:size], [self uc_coordinatesFromPoint:center]]];
}

- (NSString *)uc_cropToCenter:(CGSize)size {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%@/%@", UCDNCropKey, [self uc_dimensionsFromSize:size], UCDNCropCenter]];
}

#pragma mark - scale_crop

static NSString * const UCDNScaleCropKey = @"scale_crop";
static NSString * const UCDNScaleCropCenter = @"center";

- (NSString *)uc_scaleCrop:(CGSize)size {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%@", UCDNScaleCropKey, [self uc_dimensionsFromSize:size]]];
}

- (NSString *)uc_scaleCropToCenter:(CGSize)size {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%@/%@", UCDNScaleCropKey, [self uc_dimensionsFromSize:size], UCDNScaleCropCenter]];
}

#pragma mark - stretch

static NSString * const UCDNStretchKey = @"stretch";
static NSString * const UCDNStretchOn = @"on";
static NSString * const UCDNStretchOff = @"off";
static NSString * const UCDNStretchFill = @"fill";

- (NSString *)uc_stretch:(UCDNStretchMode)mode {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%@", UCDNStretchKey, [self stretchValueFromMode:mode]]];
}

- (NSString *)stretchValueFromMode:(UCDNStretchMode)mode {
    NSString *returnedValue = UCDNStretchOff;
    switch (mode) {
        case UCDNStretchModeOff: {
            returnedValue = UCDNStretchOff;
            break;
        }
        case UCDNStretchModeOn: {
            returnedValue = UCDNStretchOn;
            break;
        }
        case UCDNStretchModeFill: {
            returnedValue = UCDNStretchFill;
            break;
        }
    }
    return returnedValue;
}

#pragma mark - setfill

static NSString * const UCDNSetFillKey = @"setfill";

- (NSString *)uc_setFill:(UIColor *)color {
    NSParameterAssert(color);
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%@", UCDNSetFillKey, [self uc_HexStringFromColor:color]]];
}

#pragma mark - overlay

static NSString * const UCDNOverlayKey = @"overlay";
static NSString * const UCDNOverlayCenter = @"center";

- (NSString *)uc_overlay:(NSString *)uuid
   relativeDimensions:(CGSize)relativeDimensions
  relativeCoordinates:(CGPoint)relativeCoordinates
              opacity:(CGFloat)opacity {
    NSParameterAssert(uuid);
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%i%%" , [self rawOverlay:uuid relativeDimensions:relativeDimensions relativeCoordinates:relativeCoordinates], (int)opacity * 100]];
}

- (NSString *)uc_overlay:(NSString *)uuid
      relativeDimensions:(CGSize)relativeDimensions
     relativeCoordinates:(CGPoint)relativeCoordinates {
    NSParameterAssert(uuid);
    return [self uc_addParameter:[self rawOverlay:uuid relativeDimensions:relativeDimensions relativeCoordinates:relativeCoordinates]];
}

- (NSString *)uc_overlayAtCenter:(NSString *)uuid
           relativeDimensions:(CGSize)relativeDimensions
                      opacity:(CGFloat)opacity {
    NSParameterAssert(uuid);
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%i%%" , [self rawOverlayAtCenter:uuid relativeDimensions:relativeDimensions], (int)opacity * 100]];
}

- (NSString *)uc_overlayAtCenter:(NSString *)uuid
           relativeDimensions:(CGSize)relativeDimensions {
    NSParameterAssert(uuid);
    return [self uc_addParameter:[self rawOverlayAtCenter:uuid relativeDimensions:relativeDimensions]];
}

- (NSString *)rawOverlay:(NSString *)uuid
   relativeDimensions:(CGSize)relativeDimensions
  relativeCoordinates:(CGPoint)relativeCoordinates {
    return [NSString stringWithFormat:@"%@/%@/%@/%@" , UCDNOverlayKey, uuid, [self uc_dimensionsFromSize:relativeDimensions], [self uc_coordinatesFromPoint:relativeCoordinates]];
}

- (NSString *)rawOverlayAtCenter:(NSString *)uuid
           relativeDimensions:(CGSize)relativeDimensions {
    return [NSString stringWithFormat:@"%@/%@/%@/%@" , UCDNOverlayKey, uuid, [self uc_dimensionsFromSize:relativeDimensions], UCDNOverlayCenter];
}

#pragma mark - autorotate

static NSString * const UCDNAutorotateKey = @"autorotate";
static NSString * const UCDNAutorotateYes = @"yes";
static NSString * const UCDNAutorotateNo = @"no";

- (NSString *)uc_autorotate:(BOOL)autorotate {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%@", UCDNAutorotateKey, autorotate ? UCDNAutorotateYes : UCDNAutorotateNo]];
}

#pragma mark - sharp

static NSString * const UCDNSharpKey = @"sharp";

- (NSString *)uc_sharp:(NSUInteger)sharp {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%lu", UCDNSharpKey, (unsigned long)sharp]];
}

#pragma mark - blur

static NSString * const UCDNBlurKey = @"blur";

- (NSString *)uc_blur:(NSUInteger)blur {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%lu", UCDNBlurKey, (unsigned long)blur]];
}

#pragma mark - rotate

static NSString * const UCDNRotateKey = @"rotate";

- (NSString *)uc_rotate:(NSUInteger)angle {
    return [self uc_addParameter:[NSString stringWithFormat:@"%@/%lu", UCDNRotateKey, (unsigned long)angle]];
}

#pragma mark - flip

static NSString * const UCDNFlipKey = @"flip";

- (NSString *)uc_flip {
    return [self uc_addParameter:UCDNFlipKey];
}

#pragma mark - mirror

static NSString * const UCDNMirrorKey = @"mirror";

- (NSString *)uc_mirror {
    return [self uc_addParameter:UCDNMirrorKey];
}

#pragma mark - grayscale

static NSString * const UCDNGrayscaleKey = @"grayscale";

- (NSString *)uc_grayscale {
    return [self uc_addParameter:UCDNGrayscaleKey];
}

#pragma mark - invert

static NSString * const UCDNInvertKey = @"invert";

- (NSString *)uc_invert {
    return [self uc_addParameter:UCDNInvertKey];
}


#pragma mark - utilities

- (void)setIgnoreScreenScale:(BOOL)ignoreScreenScale {
    objc_setAssociatedObject(self, @selector(ignoreScreenScale), @(ignoreScreenScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ignoreScreenScale {
    NSNumber *value = objc_getAssociatedObject(self, @selector(ignoreScreenScale));
    return [value boolValue];
}

- (NSString *)uc_addParameter:(NSString *)parameter {
    return [self stringByAppendingFormat:@"%@/%@/", UCDNParameterSeparator, parameter];
}

- (NSString *)uc_HexStringFromColor:(UIColor *)color
{
    CGColorSpaceModel colorSpace = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r, g, b, a;
    
    if (colorSpace == kCGColorSpaceModelMonochrome) {
        r = components[0];
        g = components[0];
        b = components[0];
        a = components[1];
    }
    else if (colorSpace == kCGColorSpaceModelRGB) {
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255),
            lroundf(a * 255)];
}

- (NSString *)uc_oneOrTwoDimensionsFromSize:(CGSize)size {
    NSString *width = ceil(size.width) != 0 ? [NSString stringWithFormat:@"%.0f", [self scaledValue:size.width]] : @"";
    NSString *height = ceil(size.height) != 0 ? [NSString stringWithFormat:@"%.0f", [self scaledValue:size.height]] : @"";
    return [NSString stringWithFormat:@"%@x%@", width, height];
}

- (NSString *)uc_dimensionsFromSize:(CGSize)size {
    NSString *width = [NSString stringWithFormat:@"%.0f", [self scaledValue:size.width]];
    NSString *height = [NSString stringWithFormat:@"%.0f", [self scaledValue:size.height]];
    return [NSString stringWithFormat:@"%@x%@", width, height];
}

- (NSString *)uc_coordinatesFromPoint:(CGPoint)point {
    NSString *x = [NSString stringWithFormat:@"%.0f", [self scaledValue:point.x]];
    NSString *y = [NSString stringWithFormat:@"%.0f", [self scaledValue:point.y]];
    return [NSString stringWithFormat:@"%@,%@", x, y];
}

- (CGFloat) scaledValue:(CGFloat)value {
    return [self ignoreScreenScale] ? ceil(value) : ceil(value * [[UIScreen mainScreen] scale]);
};

@end

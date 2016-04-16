//
//  NSString+UCDN.m
//  ExampleProject
//
//  Created by Yury Nechaev on 15.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "NSString+UCDN.h"

static NSString * const UCDNParameterSeparator = @"/-/";
static NSString * const UCDNRootHost = @"https://ucarecdn.com";


@implementation NSString (UCDN)

#pragma mark - lifecycle

+ (instancetype)pathWithUUID:(NSString *)uuid {
    NSString *path = [[self class] initWithString:[UCDNRootHost stringByAppendingPathComponent:uuid]];
    return path;
}

#pragma mark - format

static NSString * const UCDNFormatKey = @"format";
static NSString * const UCDNFormatJpegValue = @"jpeg";
static NSString * const UCDNFormatPngValue = @"png";

- (NSString *)format:(UCDNFormat)format {
    return [self addParameter:[NSString stringWithFormat:@"%@/%@", UCDNFormatKey, [self formatValueFromFormat:format]]];
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

- (NSString *)quality:(UCDNQuality)quality {
    return [self addParameter:[NSString stringWithFormat:@"%@/%@", UCDNQualityKey, [self qualityForLevel:quality]]];
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


- (NSString *)progressive:(BOOL)progressive {
    return [self addParameter:[NSString stringWithFormat:@"%@/%@", UCDNProgressiveKey, progressive ? UCDNProgressiveYes : UCDNProgressiveNo]];
}

#pragma mark - preview

static NSString * const UCDNPreviewKey = @"preview";

- (NSString *)preview {
    return [self addParameter:UCDNPreviewKey];
}

- (NSString *)preview:(CGSize)size {
    return [self addParameter:[NSString stringWithFormat:@"%@/%@", UCDNPreviewKey, [self dimensionsFromSize:size]]];
}

#pragma mark - resize

static NSString * const UCDNResizeKey = @"resize";

- (NSString *)resize:(CGSize)size {
    return [self addParameter:[NSString stringWithFormat:@"%@/%@", UCDNResizeKey, [self dimensionsFromSize:size]]];
}

#pragma mark - crop

static NSString * const UCDNCropKey = @"crop";
static NSString * const UCDNCropCenter = @"center";


- (NSString *)crop:(CGSize)size {
    return [self addParameter:[NSString stringWithFormat:@"%@/%@", UCDNCropKey, [self dimensionsFromSize:size]]];
}

- (NSString *)crop:(CGSize)size center:(CGPoint)center {
    return [self addParameter:[NSString stringWithFormat:@"%@/%@/%@", UCDNCropKey, [self dimensionsFromSize:size], [self coordinatesFromPoint:center]]];
}

- (NSString *)cropToCenter:(CGSize)size {
    return [self addParameter:[NSString stringWithFormat:@"%@/%@/%@", UCDNCropKey, [self dimensionsFromSize:size], UCDNCropCenter]];
}

#pragma mark - scale_crop

static NSString * const UCDNScaleCropKey = @"scale_crop";
static NSString * const UCDNScaleCropCenter = @"center";

- (NSString *)scaleCrop:(CGSize)size {
    return [self addParameter:[NSString stringWithFormat:@"%@/%@", UCDNScaleCropKey, [self dimensionsFromSize:size]]];
}

- (NSString *)scaleCropToCenter:(CGSize)size {
    return [self addParameter:[NSString stringWithFormat:@"%@/%@/%@", UCDNScaleCropKey, [self dimensionsFromSize:size], UCDNScaleCropCenter]];
}

#pragma mark - stretch

static NSString * const UCDNStretchKey = @"stretch";
static NSString * const UCDNStretchOn = @"on";
static NSString * const UCDNStretchOff = @"off";
static NSString * const UCDNStretchFill = @"fill";

- (NSString *)stretch:(UCDNStretchMode)mode {
    return [self addParameter:[NSString stringWithFormat:@"%@/%@", UCDNStretchKey, [self stretchValueFromMode:mode]]];
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

- (NSString *)setFill:(UIColor *)color {
    NSParameterAssert(color);
    return [self addParameter:[NSString stringWithFormat:@"%@/%@", UCDNSetFillKey, [self ucHexStringFromColor:color]]];
}

#pragma mark - overlay

static NSString * const UCDNOverlayKey = @"overlay";
static NSString * const UCDNOverlayCenter = @"center";

- (NSString *)overlay:(NSString *)uuid
   relativeDimensions:(CGSize)relativeDimensions
  relativeCoordinates:(CGPoint)relativeCoordinates
              opacity:(CGFloat)opacity {
    NSParameterAssert(uuid);
    return [self addParameter:[NSString stringWithFormat:@"%@/%i%%" , [self rawOverlay:uuid relativeDimensions:relativeDimensions relativeCoordinates:relativeCoordinates], (int)opacity * 100]];
}

- (NSString *)overlay:(NSString *)uuid
      relativeDimensions:(CGSize)relativeDimensions
     relativeCoordinates:(CGPoint)relativeCoordinates {
    NSParameterAssert(uuid);
    return [self addParameter:[self rawOverlay:uuid relativeDimensions:relativeDimensions relativeCoordinates:relativeCoordinates]];
}

- (NSString *)overlayAtCenter:(NSString *)uuid
           relativeDimensions:(CGSize)relativeDimensions
                      opacity:(CGFloat)opacity {
    NSParameterAssert(uuid);
    return [self addParameter:[NSString stringWithFormat:@"%@/%i%%" , [self rawOverlayAtCenter:uuid relativeDimensions:relativeDimensions], (int)opacity * 100]];
}

- (NSString *)overlayAtCenter:(NSString *)uuid
           relativeDimensions:(CGSize)relativeDimensions {
    NSParameterAssert(uuid);
    return [self addParameter:[self rawOverlayAtCenter:uuid relativeDimensions:relativeDimensions]];
}

- (NSString *)rawOverlay:(NSString *)uuid
   relativeDimensions:(CGSize)relativeDimensions
  relativeCoordinates:(CGPoint)relativeCoordinates {
    return [NSString stringWithFormat:@"%@/%@/%@/%@" , UCDNOverlayKey, uuid, [self dimensionsFromSize:relativeDimensions], [self coordinatesFromPoint:relativeCoordinates]];
}

- (NSString *)rawOverlayAtCenter:(NSString *)uuid
           relativeDimensions:(CGSize)relativeDimensions {
    return [NSString stringWithFormat:@"%@/%@/%@/%@" , UCDNOverlayKey, uuid, [self dimensionsFromSize:relativeDimensions], UCDNOverlayCenter];
}

#pragma mark - autorotate

static NSString * const UCDNAutorotateKey = @"autorotate";
static NSString * const UCDNAutorotateYes = @"yes";
static NSString * const UCDNAutorotateNo = @"no";

- (NSString *)autorotate:(BOOL)autorotate {
    return [self addParameter:[NSString stringWithFormat:@"%@/%@", UCDNAutorotateKey, autorotate ? UCDNAutorotateYes : UCDNAutorotateNo]];
}

#pragma mark - sharp

static NSString * const UCDNSharpKey = @"sharp";

- (NSString *)sharp:(NSUInteger)sharp {
    NSAssert(sharp >= 0 && sharp <= 20, @"Sharp value must be in interval [0; 20]");
    return [self addParameter:[NSString stringWithFormat:@"%@/%lu", UCDNSharpKey, (unsigned long)sharp]];
}

#pragma mark - blur

static NSString * const UCDNBlurKey = @"blur";

- (NSString *)blur:(NSUInteger)blur {
    NSAssert(blur >= 0 && blur <= 5000, @"Blur value must be in interval [0; 5000]");
    return [self addParameter:[NSString stringWithFormat:@"%@/%lu", UCDNBlurKey, (unsigned long)blur]];
}

#pragma mark - rotate

static NSString * const UCDNRotateKey = @"rotate";

- (NSString *)rotate:(NSUInteger)angle {
    NSAssert(angle % 90 == 0, @"Angle must be multiple of 90");
    return [self addParameter:[NSString stringWithFormat:@"%@/%lu", UCDNRotateKey, (unsigned long)angle]];
}

#pragma mark - flip

static NSString * const UCDNFlipKey = @"flip";

- (NSString *)flip {
    return [self addParameter:UCDNFlipKey];
}

#pragma mark - mirror

static NSString * const UCDNMirrorKey = @"mirror";

- (NSString *)mirror {
    return [self addParameter:UCDNMirrorKey];
}

#pragma mark - grayscale

static NSString * const UCDNGrayscaleKey = @"grayscale";

- (NSString *)grayscale {
    return [self addParameter:UCDNGrayscaleKey];
}

#pragma mark - invert

static NSString * const UCDNInvertKey = @"invert";

- (NSString *)invert {
    return [self addParameter:UCDNInvertKey];
}


#pragma mark - utilities

- (NSString *)addParameter:(NSString *)parameter {
    return [self stringByAppendingFormat:@"%@%@", UCDNParameterSeparator, parameter];
}

- (NSString *)ucHexStringFromColor:(UIColor *)color
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

- (NSString *)dimensionsFromSize:(CGSize)size {
    NSString *width = ceil(size.width) != 0 ? [NSString stringWithFormat:@"%.0f", ceil(size.width)] : @"";
    NSString *height = ceil(size.width) != 0 ? [NSString stringWithFormat:@"%.0f", ceil(size.height)] : @"";
    return [NSString stringWithFormat:@"%@x%@", width, height];
}

- (NSString *)coordinatesFromPoint:(CGPoint)point {
    NSString *x = [NSString stringWithFormat:@"%.0f", ceil(point.x)];
    NSString *y = [NSString stringWithFormat:@"%.0f", ceil(point.y)];
    return [NSString stringWithFormat:@"%@,%@", x, y];
}

@end

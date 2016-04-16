//
//  NSString+UCDN.h
//  ExampleProject
//
//  Created by Yury Nechaev on 15.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSUInteger, UCDNFormat) {
    UCDNFormatJpeg,
    UCDNFormatPng
};

typedef NS_ENUM(NSUInteger, UCDNQuality) {
    UCDNQualityNormal,
    UCDNQualityBetter,
    UCDNQualityBest,
    UCDNQualityLighter,
    UCDNQualityLightest
};

typedef NS_ENUM(NSUInteger, UCDNStretchMode) {
    UCDNStretchModeOff,
    UCDNStretchModeOn,
    UCDNStretchModeFill
};

@interface NSString (UCDN)

+ (instancetype)pathWithUUID:(NSString *)uuid;

- (NSString *)format:(UCDNFormat)format;

- (NSString *)quality:(UCDNQuality)quality;

- (NSString *)progressive:(BOOL)progressive;

- (NSString *)preview;

- (NSString *)preview:(CGSize)size;

- (NSString *)resize:(CGSize)size;

- (NSString *)crop:(CGSize)size;

- (NSString *)crop:(CGSize)size center:(CGPoint)center;

- (NSString *)cropToCenter:(CGSize)size;

- (NSString *)scaleCrop:(CGSize)size;

- (NSString *)scaleCropToCenter:(CGSize)size;

- (NSString *)stretch:(UCDNStretchMode)mode;

- (NSString *)setFill:(UIColor *)color;

- (NSString *)overlay:(NSString *)uuid
   relativeDimensions:(CGSize)relativeDimensions
  relativeCoordinates:(CGPoint)relativeCoordinates
              opacity:(CGFloat)opacity;

- (NSString *)overlay:(NSString *)uuid
   relativeDimensions:(CGSize)relativeDimensions
  relativeCoordinates:(CGPoint)relativeCoordinates;

- (NSString *)overlayAtCenter:(NSString *)uuid
           relativeDimensions:(CGSize)relativeDimensions
                      opacity:(CGFloat)opacity;

- (NSString *)overlayAtCenter:(NSString *)uuid
           relativeDimensions:(CGSize)relativeDimensions;

- (NSString *)autorotate:(BOOL)autorotate;

- (NSString *)sharp:(NSUInteger)sharp;

- (NSString *)blur:(NSUInteger)blur;

- (NSString *)rotate:(NSUInteger)angle;

- (NSString *)flip;

- (NSString *)mirror;

- (NSString *)grayscale;

- (NSString *)invert;

@end

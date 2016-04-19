//
//  UCAlbumGalleryCell.m
//  ExampleProject
//
//  Created by Yury Nechaev on 19.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCAlbumGalleryCell.h"

static NSString *const kCellIdentifier = @"albumCell";

#define STROKE_COLOR [UIColor colorWithRed: 0.365 green: 0.365 blue: 0.365 alpha: 1]
#define STROKE_HEIGHT 6.0
#define TITLE_HEIGHT 30.0

@interface UCStrokeView : UIView
@end

@implementation UCStrokeView

- (void)drawRect:(CGRect)rect {
    //// Color Declarations
    UIColor* strokeColor = STROKE_COLOR;
    
    //// Frames
    CGRect frame = rect;
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 8, CGRectGetMinY(frame) + 1)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame) - 8, CGRectGetMinY(frame) + 1)];
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    
    //// Middle line Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 6, CGRectGetMinY(frame) + 3)];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMaxX(frame) - 6, CGRectGetMinY(frame) + 3)];
    [strokeColor setStroke];
    bezier3Path.lineWidth = 1;
    [bezier3Path stroke];
    
    //// Lower line Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 4, CGRectGetMinY(frame) + 5)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMaxX(frame) - 4, CGRectGetMinY(frame) + 5)];
    [strokeColor setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
}

@end

@implementation UCAlbumGalleryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.titleLabel.numberOfLines = 3;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.5;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.imageView.layer.borderColor = STROKE_COLOR.CGColor;
        self.imageView.layer.borderWidth = 1.0;
        UIView *strokeView = [[UCStrokeView alloc] init];
        strokeView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:strokeView];
        [strokeView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = @{@"imageView":self.imageView,
                                @"title":self.titleLabel,
                                @"stroke":strokeView};
        NSDictionary *metrics = @{@"strokeHeight":@(STROKE_HEIGHT),
                                  @"titleHeight":@(TITLE_HEIGHT)};
        NSArray *horizontal1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views];
        NSArray *horizontal2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title]|" options:0 metrics:nil views:views];
        NSArray *horizontal3 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stroke]|" options:0 metrics:nil views:views];
        NSArray *vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[stroke(strokeHeight)][imageView][title(titleHeight)]|" options:0 metrics:metrics views:views];
        [self.contentView addConstraints:horizontal1];
        [self.contentView addConstraints:horizontal2];
        [self.contentView addConstraints:horizontal3];
        [self.contentView addConstraints:vertical];
    }
    return self;
}

+ (CGFloat)heightFromWidthConstant:(CGFloat)width {
    return STROKE_HEIGHT + TITLE_HEIGHT;
}

+ (NSString *)cellIdentifier {
    return kCellIdentifier;
}

@end

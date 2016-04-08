//
//  UCGalleryCell.m
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCGalleryCell.h"
#import "UCSocialEntry.h"
#import "UCClient.h"
#import "UIImageView+Uploadcare.h"

@implementation UCGalleryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView.layer setShouldRasterize:YES];
        self.contentView.backgroundColor = [UIColor colorWithWhite:.73 alpha:1.0];
        _imageView = [[UIImageView alloc]init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.frame = frame;
        [self.contentView addSubview:self.imageView];
        NSDictionary *views = @{@"imageView":self.imageView};
        [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views];
        NSArray *vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:horizontal];
        [self.contentView addConstraints:vertical];
    }
    return self;
}

- (void)setSocialEntry:(UCSocialEntry *)socialEntry {
    if (![_socialEntry isEqual:socialEntry]) {
        self.imageView.image = nil;
        [self.imageView uc_setImageWithURL:[NSURL URLWithString:socialEntry.thumbnail] usingSession:[[UCClient defaultClient] session] cache:[[UCClient defaultClient] cache]];
    }
    _socialEntry = socialEntry;
}

@end

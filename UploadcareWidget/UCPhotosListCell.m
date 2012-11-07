//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCPhotosListCell.h"

#import "UploadcareKit.h"
#import "UCUploader.h"
#import "UIImageView+UCHelpers.h"

#import "GRKPhoto.h"
#import "GRKImage.h"

#define UCImageWillUploadNotification @"UCImageWillUploadNotification" // FIXME extern const NSString

@interface UCPhotosListCell()
- (void)updateThumbnails;
@end

@implementation UCPhotosListCell
@synthesize photos = _photos;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {        
    }
    return self;
}

- (void)prepareForReuse {
    _photos = nil;
            
    [photoThumbnail3 setHidden:NO];
    [photoThumbnail2 setHidden:NO];
    [photoThumbnail1 setHidden:NO];
    [photoThumbnail0 setHidden:NO];
}

- (void)setPhotos:(NSArray *)newPhotos {
    _photos = newPhotos;
        
    switch ([_photos count]) {
        case 0:
            [photoThumbnail0 setHidden:YES];
        case 1:
            [photoThumbnail1 setHidden:YES];
        case 2:
            [photoThumbnail2 setHidden:YES];
        case 3:
            [photoThumbnail3 setHidden:YES];
            break;
    }
    [self updateThumbnails];    
}

- (void)updateThumbnail:(UIImageView *)thumbnail withPhoto:(GRKPhoto *)photo {
    NSURL * thumbnailURL = [[photo imagesSortedByHeight][0] URL];
    [thumbnail setImageFromURL:thumbnailURL scaledToSize:CGSizeMake(75, 75) placeholderImage:nil showActivityIndicator:YES withStyle:UIActivityIndicatorViewStyleGray];
}

- (void)updateThumbnails {
    [photoThumbnail0 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelected:)]];
    [photoThumbnail1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelected:)]];
    [photoThumbnail2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelected:)]];
    [photoThumbnail3 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelected:)]];
    
    switch ([_photos count]) {            
        case 4:
            [self updateThumbnail:photoThumbnail3 withPhoto:[_photos objectAtIndex:3]];
        case 3:
            [self updateThumbnail:photoThumbnail2 withPhoto:[_photos objectAtIndex:2]];
        case 2:
            [self updateThumbnail:photoThumbnail1 withPhoto:[_photos objectAtIndex:1]];
        case 1:
            [self updateThumbnail:photoThumbnail0 withPhoto:[_photos objectAtIndex:0]];
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)didSelected:(id)sender {
    UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer *)sender;
    UIImageView *tappedImageView = (UIImageView *)[tapGesture view];
    GRKPhoto *photo = (GRKPhoto *)[_photos objectAtIndex:[tappedImageView tag]];
    [self.photoList.navigationController dismissViewControllerAnimated:YES completion:^{
        UCUploadFile([photo.imagesSortedByHeight.lastObject URL].absoluteString, self.photoList.albumList.uploadCompletionBlock, self.photoList.albumList.uploadFailureBlock);
    }];
}

@end

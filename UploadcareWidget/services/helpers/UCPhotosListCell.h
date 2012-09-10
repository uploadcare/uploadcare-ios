//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UCPhotosList.h"

@interface UCPhotosListCell : UITableViewCell {
    NSArray * _photos;
    
    IBOutlet UIImageView *photoThumbnail0;
    IBOutlet UIImageView *photoThumbnail1;
    IBOutlet UIImageView *photoThumbnail2;
    IBOutlet UIImageView *photoThumbnail3;
}

@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) UCPhotosList *photoList;

- (void)updateThumbnails;

@end

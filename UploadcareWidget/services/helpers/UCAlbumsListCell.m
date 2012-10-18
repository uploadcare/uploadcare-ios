//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCAlbumsListCell.h"

#import "UploadcareKit.h"
#import "UploadcareKit+Deprecated.h"

@implementation UCAlbumsListCell

@synthesize thumbnail;
@synthesize labelAlbumName;
@synthesize labelPhotosCount;
@synthesize labelDateCreated;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setAlbum:(GRKAlbum *)_newAlbum {
    _album = _newAlbum;
    
    labelAlbumName.text = _album.name;
    labelPhotosCount.text = [NSString stringWithFormat:NSLocalizedString(@"%d Photos", nil), _album.count];
    
    if ([_album dateForProperty:kGRKAlbumDatePropertyDateCreated] != nil) {
        labelDateCreated.hidden = NO;
        labelDateCreated.text = [NSLocalizedString(@"Created ", nil) stringByAppendingString:[[_album dateForProperty:kGRKAlbumDatePropertyDateCreated] description]];
    } else {
        labelDateCreated.hidden = YES;
    }
            
    if (_album.coverPhoto != nil) {
        NSURL * thumbnailURL = nil;
        for(GRKImage *image in [_album.coverPhoto imagesSortedByHeight]) {
            if (image.width > 75) {
                thumbnailURL = image.URL;
                break;
            }
        }
        
        [UploadcareKit downloadImageAtURL:thumbnailURL withPlaceholder:nil forImageView:thumbnail];
    }
}

- (void)prepareForReuse {    
    [thumbnail setImage:nil];
    labelAlbumName.text = @"";
    labelPhotosCount.text = @"";
    labelDateCreated.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

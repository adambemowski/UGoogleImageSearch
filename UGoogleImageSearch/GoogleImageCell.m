//
//  GoogleImageCell.m
//  UGoogleImageSearch
//
//  Created by Adam Bemowski on 4/21/13.
//  Copyright (c) 2013 BEMO. All rights reserved.
//

#import "GoogleImageCell.h"
#import "UIImageView+AFNetworking.h"


@interface GoogleImageCell ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end


@implementation GoogleImageCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCellImageWithURL:(NSString *)URL
{
    [self.imageView setImageWithURL:[NSURL URLWithString:URL]];
}

@end

//
//  ImageView.m
//  Universal
//
//  Created by Mu-Sonic on 20/11/2015.
//  Copyright © 2018 Sherdle. All rights reserved.
//

#import "ImageView.h"

@interface ImageView ()
@property (nonatomic, strong) NSLayoutConstraint *aspectRatio;
@end

@implementation ImageView

- (void)updateAspectRatio
{
    if (self.aspectRatio) {
        [self removeConstraint:self.aspectRatio];
    }

    if (!self.image) return;
    
    CGFloat aspectRatioValue = self.image.size.height / self.image.size.width;
    self.aspectRatio = [NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self
                                                    attribute:NSLayoutAttributeWidth
                                                   multiplier:aspectRatioValue
                                                     constant:0.f];
    [self addConstraint:self.aspectRatio];
}

@end

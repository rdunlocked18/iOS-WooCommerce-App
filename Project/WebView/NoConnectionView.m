//
//  NoConnectionView.m
//
//  Copyright (c) 2018 Sherdle. All rights reserved.
//

#import "NoConnectionView.h"

@implementation NoConnectionView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.retryButton.layer.cornerRadius = 5.f;
}

@end

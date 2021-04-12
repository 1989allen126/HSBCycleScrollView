//
//  HSBCycleScrollViewCell.m
//  HSBCycleScrollView
//
//  Created by apple on 2021/4/12.
//  Copyright © 2021 1989allen126. All rights reserved.
//

#import "HSBCycleScrollViewCell.h"
#import "UIView+HSBExtension.h"

@implementation HSBCycleScrollViewCell

- (UIImageView *)imageView {
    if(!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setupUIElements];
    }
    return self;
}

- (void)setupUIElements {
    [self.contentView addSubview:self.imageView];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

@end

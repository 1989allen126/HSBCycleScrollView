//
//  UIView+HSBExtension.h
//  HSBCycleScrollView
//
//  Created by apple on 2021/4/12.
//  Copyright © 2021 1989allen126. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (HSBExtension)

@property (nonatomic, assign) CGFloat hsb_x;
@property (nonatomic, assign) CGFloat hsb_y;
@property (nonatomic, assign) CGFloat hsb_centerX;
@property (nonatomic, assign) CGFloat hsb_centerY;
@property (nonatomic, assign) CGFloat hsb_width;
@property (nonatomic, assign) CGFloat hsb_height;
@property (nonatomic, assign) CGSize hsb_size;

@property (nonatomic, assign) CGFloat hsb_top;
@property (nonatomic, assign) CGFloat hsb_bottom;
@property (nonatomic, assign) CGFloat hsb_left;
@property (nonatomic, assign) CGFloat hsb_right;
@end

NS_ASSUME_NONNULL_END

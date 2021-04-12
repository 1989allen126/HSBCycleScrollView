//
//  UIView+HSBExtension.m
//  HSBCycleScrollView
//
//  Created by apple on 2021/4/12.
//  Copyright © 2021 1989allen126. All rights reserved.
//

#import "UIView+HSBExtension.h"

@implementation UIView (HSBExtension)

- (void)setHsb_x:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)hsb_x {
    return self.frame.origin.x;
}

- (void)setHsb_y:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)hsb_y {
    return self.frame.origin.y;
}

- (void)setHsb_centerX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)hsb_centerX {
    return self.center.x;
}

- (void)setHsb_centerY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)hsb_centerY {
    return self.center.y;
}

- (void)setHsb_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)hsb_width {
    return self.frame.size.width;
}

- (void)setHsb_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)hsb_height {
    return self.frame.size.height;
}

- (void)setHsb_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)hsb_size {
    return self.frame.size;
}

- (void)setHsb_top:(CGFloat)t {
    self.frame = CGRectMake(self.hsb_left, t, self.hsb_width, self.hsb_height);
}

- (CGFloat)hsb_top {
    return self.frame.origin.y;
}

- (void)setHsb_bottom:(CGFloat)b {
    self.frame = CGRectMake(self.hsb_left, b - self.hsb_height, self.hsb_width, self.hsb_height);
}

- (CGFloat)hsb_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setHsb_left:(CGFloat)l {
    self.frame = CGRectMake(l, self.hsb_top, self.hsb_width, self.hsb_height);
}

- (CGFloat)hsb_left {
    return self.frame.origin.x;
}

- (void)setHsb_right:(CGFloat)r {
    self.frame = CGRectMake(r - self.hsb_width, self.hsb_top, self.hsb_width, self.hsb_height);
}

- (CGFloat)hsb_right {
    return self.frame.origin.x + self.frame.size.width;
}
@end

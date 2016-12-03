//
//  UIView+FrameHelper.m
//  SelectionView
//
//  Created by xiaotu on 2016/11/9.
//  Copyright © 2016年 personal. All rights reserved.
//

#import "UIView+FrameHelper.h"

@implementation UIView (FrameHelper)

- (void)setX:(CGFloat)x
{
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect rect = self.frame;
    rect.origin.y = y;
    self.frame = rect;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

@end

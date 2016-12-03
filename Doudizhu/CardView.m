//
//  CardView.m
//  Doudizhu
//
//  Created by xiaotu on 2016/11/28.
//  Copyright © 2016年 personal. All rights reserved.
//

#import "CardView.h"

#define CornerRatio 0.1
#define FontRatio 0.2

@implementation CardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isRevearsed = YES;
    }
    return self;
}

- (void)setCard:(Card *)card {
    _card = card;
    [self setNeedsDisplay];
}

- (void)setIsRevearsed:(BOOL)isRevearsed {
    _isRevearsed = isRevearsed;
    [self setNeedsDisplay];
}

#pragma mark - draw
- (void)drawRect:(CGRect)rect {
    [self drawBackground];
    if (!_isRevearsed) {
        UIColor *color = [self getColor:_card];
        [self drawNumberWithColor:color];
    } else {
        [self drawBack];
    }
}

- (void)drawBackground {
    UIBezierPath *roundRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.width * CornerRatio];
    [roundRect addClip];
    
    [[UIColor whiteColor] setFill];
    UIRectFill(self.bounds);
    
    [[UIColor blackColor] setStroke];
    [roundRect stroke];
}

- (void)drawNumberWithColor:(UIColor *)color {
    NSString *string = [NSString stringWithFormat:@"%@\n%@", [self getNumberDescroption:_card], [self getSuitsDescription:_card]];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
    if (_card.suits != SuitsNull) {
        [attributeString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.width * FontRatio] range:NSMakeRange(0, attributeString.length - 2)];
        [attributeString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.width * FontRatio * 0.75] range:NSMakeRange(attributeString.length - 2, 2)];
    } else {
        [attributeString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.width * FontRatio] range:NSMakeRange(0, attributeString.length)];
    }
    [attributeString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attributeString.length)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributeString.length)];
    
    // 绘制左上角
    CGRect frame;
    frame.origin = CGPointMake(0, self.width * CornerRatio);
    frame.size = CGSizeMake(self.width * FontRatio * 2, self.height * FontRatio * 5);

    [attributeString drawInRect:frame];
    
    // 绘制右下角
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, self.width, self.height);
    CGContextRotateCTM(context, M_PI);
    
    [attributeString drawInRect:frame];
}

- (void)drawBack {
    UIImage *image = [[UIImage imageNamed:@"icon_card_back"] imageByScalingToSize:self.frame.size];
//    [image drawInRect:self.frame];
    [image drawAtPoint:CGPointMake(0, 0)];
}

#pragma mark - other
- (UIColor *)getColor:(Card *)card {
    UIColor *color;
    if (card.suits == SuitsHei || card.suits == SuitsMei || card.number == NumberSmallKing) {
        color = [UIColor blackColor];
    } else if (card.suits == SuitsHong || card.suits == SuitsFang || card.number == NumberBigKing) {
        color = [UIColor redColor];
    } else {
        color = [UIColor whiteColor];
    }
    return color;
}

- (NSString *)getNumberDescroption:(Card *)card {
    NSString *description;
    switch (card.number) {
        case Number3:
            description = @"3";
            break;
        case Number4:
            description = @"4";
            break;
        case Number5:
            description = @"5";
            break;
        case Number6:
            description = @"6";
            break;
        case Number7:
            description = @"7";
            break;
        case Number8:
            description = @"8";
            break;
        case Number9:
            description = @"9";
            break;
        case Number10:
            description = @"10";
            break;
        case NumberJ:
            description = @"J";
            break;
        case NumberQ:
            description = @"Q";
            break;
        case NumberK:
            description = @"K";
            break;
        case NumberA:
            description = @"A";
            break;
        case Number2:
            description = @"2";
            break;
        case NumberSmallKing:
            description = @"J\nO\nK\nE\nR";
            break;
        case NumberBigKing:
            description = @"J\nO\nK\nE\nR";
            break;
        default:
            break;
    }
    return description;
}

- (NSString *)getSuitsDescription:(Card *)card {
    NSString *description;
    switch (card.suits) {
        case SuitsNull:
            description = @"";
            break;
        case SuitsHei:
            description = @"♠️";
            break;
        case SuitsHong:
            description = @"♥️";
            break;
        case SuitsMei:
            description = @"♣️";
            break;
        case SuitsFang:
            description = @"♦️";
            break;
        default:
            break;
    }
    return description;
}

@end

//
//  Card.h
//  Doudizhu
//
//  Created by xiaotu on 2016/11/28.
//  Copyright © 2016年 personal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, Number) {
    Number3 = 0,
    Number4,
    Number5,
    Number6,
    Number7,
    Number8,
    Number9,
    Number10,
    NumberJ,
    NumberQ,
    NumberK,
    NumberA,
    Number2,
    NumberSmallKing,
    NumberBigKing
};

typedef NS_ENUM(NSInteger, Suits) {
    SuitsFang = 0,
    SuitsMei,
    SuitsHong,
    SuitsHei,
    SuitsNull
};

typedef NS_ENUM(NSInteger, Color) {
    ColorBlack = 0,
    ColorRed
};

@interface Card : NSObject

@property (nonatomic, assign) int index;    // 1：方片3 2：梅花3 3：红桃3 4：黑桃3……
@property (nonatomic, assign) Number number;   // 数字，大小王为0
@property (nonatomic, assign) Suits suits;    // 1 2 3 4 黑红梅方，大小王为0
@property (nonatomic, assign) Color color;

@end

//
//  Cards.h
//  Doudizhu
//
//  Created by xiaotu on 2016/12/1.
//  Copyright © 2016年 personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

typedef NS_ENUM(NSInteger, Type) {
    TypeNormal = 0, // 手牌
    TypeKingBomb,   // 王炸
    TypeNormalBomb, // 普通炸弹
    TypeStraight,   // 顺
    TypeCompany,    // 连队
    TypePlane,      // 飞机
    TypeFour,       // 四带二
    TypeThree,      // 三带
    TypeDouble,     // 对子
    TypeSingle,     // 单张
    TypeIllegal     // 不合法
};

@interface Cards : NSObject

@property (nonatomic, strong) NSMutableArray *cardList;
@property (nonatomic, assign) Type type;
@property (nonatomic, assign) int count;

@end

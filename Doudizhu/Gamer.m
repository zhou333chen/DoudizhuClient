//
//  Gamer.m
//  Doudizhu
//
//  Created by xiaotu on 2016/11/30.
//  Copyright © 2016年 personal. All rights reserved.
//

#import "Gamer.h"

@implementation Gamer

- (instancetype)init {
    self = [super init];
    if (self) {
        _cards = [[Cards alloc] init];
        _cards.cardList = [NSMutableArray array];
    }
    return self;
}

@end

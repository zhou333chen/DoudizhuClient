//
//  Cards.m
//  Doudizhu
//
//  Created by xiaotu on 2016/12/1.
//  Copyright © 2016年 personal. All rights reserved.
//

#import "Cards.h"

@implementation Cards

- (instancetype)init {
    self = [super init];
    if (self) {
        _cardList = [NSMutableArray array];
    }
    return self;
}

- (void)setCardList:(NSMutableArray *)cardList {
    _cardList = cardList;
}

- (int)count {
    return (int)_cardList.count;
}
@end

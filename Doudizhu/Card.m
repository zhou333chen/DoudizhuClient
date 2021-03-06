//
//  Card.m
//  Doudizhu
//
//  Created by xiaotu on 2016/11/28.
//  Copyright © 2016年 personal. All rights reserved.
//

#import "Card.h"

@implementation Card

- (void)setIndex:(int)index {
    _index = index;
    if (index == 53) {
        _number = NumberSmallKing;
        _suits = SuitsNull;
    } else if (index == 54) {
        _number = NumberBigKing;
        _suits = SuitsNull;
    } else {
        _number = (index - 1 ) / 4;
        _suits = (index - 1 ) % 4;
    }
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    Card *card = (Card *)object;
    if (_index == card.index) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return 5000 + _index;
}

@end

//
//  GameView.h
//  Doudizhu
//
//  Created by xiaotu on 2016/11/30.
//  Copyright © 2016年 personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomCardsView.h"
#import "CardsView.h"

typedef NS_ENUM(NSInteger, Landlord) {
    LandlordMe = 0,
    LandlordNext,
    LandlordLast
};

@interface GameView : UIView

@property (nonatomic, strong) CardsView *myCardsView;   // 我的手牌
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *passBtn;
@property (nonatomic, strong) NSMutableArray *playCardViews;
@property (nonatomic, strong) NSMutableArray *passLabels;
@property (nonatomic, strong) NSMutableArray *waitImgs;
@property (nonatomic, strong) NSMutableArray *countLabels;
@property (nonatomic, strong) BottomCardsView *bottomCardsView; // 底牌

- (void)setLandlord:(Landlord)landlord;
- (void)reset;

@end

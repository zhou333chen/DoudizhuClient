//
//  CardsView.m
//  Doudizhu
//
//  Created by xiaotu on 2016/11/28.
//  Copyright © 2016年 personal. All rights reserved.
//

#import "CardsView.h"
#import "CardView.h"

#define ChooseCardHeightRatio 0.1

@interface CardsView()

@property (nonatomic, strong) NSMutableArray *cardViews;
@property (nonatomic, assign) CGFloat cardWidth;
@property (nonatomic, assign) CGFloat cardHeight;

@end

@implementation CardsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat basicWidthPixel = self.width / (_cardWidth * (1 + 19 * (1 - OVERLAY_RATIO))) / BasicWidth;
        CGFloat basicHeightPixel = self.height * (1 - ChooseCardHeightRatio) / BasicHeight;
        CGFloat basicPixel = MIN(basicWidthPixel, basicHeightPixel);
        _cardWidth = basicPixel * BasicWidth;
        _cardHeight = basicPixel * BasicHeight;
        _choosedCards = [[Cards alloc] init];
        _cardViews = [NSMutableArray array];
    }
    return self;
}

- (void)setCards:(Cards *)cards clickable:(BOOL)clickable {
    [_choosedCards.cardList removeAllObjects];
    
    CGFloat x = self.width / 2 - _cardWidth * (1 + (cards.count - 1) * (1 - OVERLAY_RATIO)) / 2;
    // 隐藏之前的扑克牌容器
    for (int i=0;i<_cardViews.count;i++) {
        CardView *cardView = _cardViews[i];
        cardView.hidden = YES;
    }
    // 渲染扑克牌容器并显示
    for (int i=0;i<cards.count;i++) {
        if (_cardViews.count <= i) {
            // 懒加载
            CardView *cardView = [[CardView alloc] init];
            [cardView addTarget:self action:@selector(cardClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_cardViews addObject:cardView];
            [self addSubview:cardView];
        }
        CardView *cardView = _cardViews[i];
        cardView.frame = CGRectMake(x + _cardWidth * i * (1 - OVERLAY_RATIO), self.height * 0.1, _cardWidth, _cardHeight);
        cardView.hidden = NO;
        cardView.isRevearsed = NO;
        cardView.isChoosed = NO;
        cardView.backgroundColor = [UIColor clearColor];
        cardView.card = cards.cardList[i];
        
        if (clickable) {
            cardView.enabled = YES;
        } else {
            cardView.enabled = NO;
        }
    }
}

- (void)showBack {
    CardView *cardView = [[CardView alloc] initWithFrame:CGRectMake(self.width / 2 - _cardWidth / 2, self.height * 0.1, _cardWidth, _cardHeight)];
    cardView.isRevearsed = YES;
    [_cardViews addObject:cardView];
    [self addSubview:cardView];
}

- (void)cardClicked:(CardView *)cardView {
    if (cardView.isChoosed) {
        cardView.y += ChooseCardHeightRatio * _cardHeight;
        cardView.isChoosed = NO;
        [_choosedCards.cardList removeObject:cardView.card];
    } else {
        cardView.y -= ChooseCardHeightRatio * _cardHeight;
        cardView.isChoosed = YES;
        [_choosedCards.cardList addObject:cardView.card];
    }
}

@end

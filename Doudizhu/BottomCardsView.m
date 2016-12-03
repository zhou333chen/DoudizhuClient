//
//  BottomCardsView.m
//  Doudizhu
//
//  Created by xiaotu on 2016/11/29.
//  Copyright © 2016年 personal. All rights reserved.
//

#import "BottomCardsView.h"
#import "Card.h"
#import "CardView.h"

#define WidthRatio 3.3   // 1 + 0.15 + 1 + 0.15 + 1

@interface BottomCardsView()

@property (nonatomic, strong) NSMutableArray *cardViews;
@property (nonatomic, assign) CGFloat cardWidth;
@property (nonatomic, assign) CGFloat cardHeight;
@property (nonatomic, assign) CGFloat cardInterval;
@property (nonatomic, assign) CGRect originalFrame;

@end

@implementation BottomCardsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _originalFrame = frame;
        
        CGFloat basicWidthPixel = self.width / WidthRatio / BasicWidth;
        CGFloat basicHeightPixel = self.height / BasicHeight;
        CGFloat basicPixel = MIN(basicWidthPixel, basicHeightPixel);
        _cardWidth = basicPixel * BasicWidth;
        _cardHeight = basicPixel * BasicHeight;
        _cardInterval = (self.width - 3 * _cardWidth) / 2;
        _cardViews = [NSMutableArray array];
        [self addCardsView];
    }
    return self;
}

- (void)setCards:(NSArray *)cards {
    for (int i=0; i<cards.count; i++) {
        CardView *cardView = _cardViews[i];
        cardView.isRevearsed = NO;
        cardView.card = cards[i];
    }
    self.clipsToBounds = YES;
    [UIView animateWithDuration:1.0 animations:^{
        self.width *= 0.8;
        self.height *= 0.32;
        self.x += self.width * 0.1;
        self.y = 0;
        for (int i=0; i<3; i++) {
            CardView *cardView = _cardViews[i];
            cardView.x = self.width / 10 * (0.5 + 3 * i);
        }
    } completion:^(BOOL finished) {
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
    }];
}

- (void)reset {
    self.frame = _originalFrame;
    self.layer.borderWidth = 0;
    for (int i=0; i<_cardViews.count; i++) {
        CardView *cardView = _cardViews[i];
        cardView.isRevearsed = YES;
        cardView.frame = CGRectMake(i * (_cardWidth + _cardInterval), 0, _cardWidth, _cardHeight);

    }
}

- (void)addCardsView {
    for (int i=0; i<3; i++) {
        CardView *cardView = [[CardView alloc] initWithFrame:CGRectMake(i * (_cardWidth + _cardInterval), 0, _cardWidth, _cardHeight)];
        cardView.isRevearsed = YES;
        [self addSubview:cardView];
        [_cardViews addObject:cardView];
    }
}

@end

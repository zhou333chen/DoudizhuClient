
//
//  GameView.m
//  Doudizhu
//
//  Created by xiaotu on 2016/11/30.
//  Copyright © 2016年 personal. All rights reserved.
//

#import "GameView.h"

#define BottomCardsViewWidthRatio 0.3
#define BottomCardsViewHeightRatio 0.2
#define CardsViewWidthRatio 0.8
#define CardsViewHeightRatio 0.3
#define PlayCardsViewWidthRatio 0.35
#define PlayCardsViewHeightRatio 0.25
#define HeightSpace 0.01
#define OtherCardViewWidthRatio 0.15
#define OtherCardViewHeightRatio 0.3
#define BtnWidth 80
#define BtnHeight 30
#define BtnXSpace 50
#define BtnYSpace 10
#define ClockSize 25
#define CountWidth 50
#define CountHeight 20

@interface GameView()

@property (nonatomic, strong) CardsView *nextCardsView; // 下家的手牌
@property (nonatomic, strong) CardsView *lastCardsView; // 上家的手牌
@property (nonatomic, strong) CardsView *myPlayCardsView;  // 我出的牌
@property (nonatomic, strong) CardsView *nextPlayCardsView;    // 下家出的牌
@property (nonatomic, strong) CardsView *lastPlayCardsView;    // 上家出的牌
@property (nonatomic, strong) UIImageView *nextWaitImg;
@property (nonatomic, strong) UIImageView *lastWaitImg;
@property (nonatomic, strong) UILabel *nextCountLabel;
@property (nonatomic, strong) UILabel *lastCountLabel;
@property (nonatomic, strong) UILabel *myPassLabel;
@property (nonatomic, strong) UILabel *nextPassLabel;
@property (nonatomic, strong) UILabel *lastPassLabel;
@property (nonatomic, strong) UIImageView *landlordImg;

@end

@implementation GameView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _playCardViews = [NSMutableArray array];
        _passLabels = [NSMutableArray array];
        _waitImgs = [NSMutableArray array];
        [_waitImgs addObject:[[NSObject alloc] init]];
        _countLabels = [NSMutableArray array];
        [_countLabels addObject:[[NSObject alloc] init]];
        
        [self addButton];
        [self addBottomCardView];
        [self addMyCardView];
        [self addNextCardView];
        [self addLastCardView];

    }
    return self;
}

- (void)setLandlord:(Landlord)landlord {
    UIImageView *landlordImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_landlord"]];
    landlordImg.width = 30;
    landlordImg.height = 30;
    switch (landlord) {
        case LandlordMe:
            landlordImg.x = 40;
            landlordImg.y = _myCardsView.y + _myCardsView.height / 2 - 15;
            break;
        case LandlordNext:
            landlordImg.x = _nextCardsView.x + _nextCardsView.width / 2 - 15;
            landlordImg.y = 5;
            break;
        case LandlordLast:
            landlordImg.x = _lastCardsView.x + _lastCardsView.width / 2 - 15;
            landlordImg.y = 5;
            break;
        default:
            break;
    }
    [self addSubview:landlordImg];
}

- (void)reset {
    for (CardsView *cardView in _playCardViews) {
        if ([cardView respondsToSelector:@selector(setCards:clickable:)]) {
            [cardView setCards:nil clickable:NO];
        }
    }
    
    for (UIView *view in _passLabels) {
        if ([view respondsToSelector:@selector(setHidden:)]) {
            view.hidden = YES;
        }
    }
    
    for (UILabel *label in _countLabels) {
        if ([label respondsToSelector:@selector(setText:)]) {
            label.text = @"17";
        }
    }
    
    [_bottomCardsView reset];
}

#pragma mark - setupUI
- (void)addButton {
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width * 0.5 - BtnWidth - BtnXSpace, self.height * (1 - CardsViewHeightRatio) - BtnHeight - BtnYSpace, BtnWidth, BtnHeight)];
    playBtn.hidden = YES;
    playBtn.layer.masksToBounds = YES;
    playBtn.layer.cornerRadius = playBtn.height * 0.1;
    playBtn.backgroundColor = [UIColor colorWithHexString:@"#1164a2"];
    playBtn.titleLabel.font = [UIFont boldSystemFontOfSize:playBtn.height / 2];
    [playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [playBtn setTitle:@"出牌" forState:UIControlStateNormal];
    [self addSubview:playBtn];
    _playBtn = playBtn;
    
    UIButton *passBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width * 0.5 + BtnXSpace, self.height * (1 - CardsViewHeightRatio) - BtnHeight - BtnYSpace, BtnWidth, BtnHeight)];
    passBtn.hidden = YES;
    passBtn.layer.masksToBounds = YES;
    passBtn.layer.cornerRadius = passBtn.height * 0.1;
    passBtn.backgroundColor = [UIColor colorWithHexString:@"#d55351"];
    passBtn.titleLabel.font = [UIFont boldSystemFontOfSize:playBtn.height / 2];
    [passBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [passBtn setTitle:@"不要" forState:UIControlStateNormal];
    [self addSubview:passBtn];
    _passBtn = passBtn;
}

- (void)addBottomCardView {
    BottomCardsView *bottomCardsView = [[BottomCardsView alloc] initWithFrame:
                                        CGRectMake(self.width * (0.5 - BottomCardsViewWidthRatio / 2),
                                                   20,
                                                   self.width * BottomCardsViewWidthRatio,
                                                   self.height * BottomCardsViewHeightRatio)];
    [self addSubview:bottomCardsView];
    _bottomCardsView = bottomCardsView;
}

- (void)addMyCardView {
    CardsView *myCardsView = [[CardsView alloc] initWithFrame:
                              CGRectMake(self.width * (0.5 - CardsViewWidthRatio / 2),
                                         self.height * (1 - HeightSpace - CardsViewHeightRatio),
                                         self.width * CardsViewWidthRatio,
                                         self.height * CardsViewHeightRatio)];
    [self addSubview:myCardsView];
    _myCardsView = myCardsView;
    
    CardsView *myPlayCardsView = [[CardsView alloc] initWithFrame:
                                  CGRectMake(self.width * (0.5 - PlayCardsViewWidthRatio / 2),
                                             self.height * (1 - PlayCardsViewHeightRatio - CardsViewHeightRatio) - BtnHeight - BtnYSpace * 2,
                                             self.width * PlayCardsViewWidthRatio,
                                             self.height * PlayCardsViewHeightRatio)];
    [self addSubview:myPlayCardsView];
    [_playCardViews addObject:myPlayCardsView];
    _myPlayCardsView = myPlayCardsView;
    
    UILabel *myPass = [[UILabel alloc] initWithFrame:CGRectMake(self.width / 2 - 50, _passBtn.y, 100, 30)];
    myPass.textColor = [UIColor colorWithHexString:@"#d55351"];
    myPass.font = [UIFont boldSystemFontOfSize:20];
    myPass.textAlignment = NSTextAlignmentCenter;
    myPass.hidden = YES;
    myPass.text = @"不要";
    [self addSubview:myPass];
    [_passLabels addObject:myPass];
    _myPassLabel = myPass;
}

- (void)addNextCardView {
    CardsView *nextCardsView = [[CardsView alloc] initWithFrame:
                                CGRectMake(self.width * (1 - OtherCardViewWidthRatio),
                                           self.height * (1 - 2 * PlayCardsViewHeightRatio - CardsViewHeightRatio) - BtnHeight - BtnYSpace * 2,
                                           self.width * OtherCardViewWidthRatio,
                                           self.height * OtherCardViewHeightRatio)];
    [nextCardsView showBack];
    [self addSubview:nextCardsView];
    _nextCardsView = nextCardsView;
    
    CardsView *nextPlayCardsView = [[CardsView alloc] initWithFrame:
                                    CGRectMake(self.width * (1 - OtherCardViewWidthRatio - PlayCardsViewWidthRatio),
                                               self.height * (1 - 2 * PlayCardsViewHeightRatio - CardsViewHeightRatio) - BtnHeight - BtnYSpace * 2,
                                               self.width * PlayCardsViewWidthRatio - ClockSize,
                                               self.height * PlayCardsViewHeightRatio)];
    [self addSubview:nextPlayCardsView];
    [_playCardViews addObject:nextPlayCardsView];
    _nextPlayCardsView = nextPlayCardsView;
    
    UIImageView *nextWaitImg = [[UIImageView alloc] initWithFrame:
                                CGRectMake(nextPlayCardsView.x + nextPlayCardsView.width,
                                           nextPlayCardsView.y,
                                           ClockSize,
                                           ClockSize)];
    nextWaitImg.image = [UIImage imageNamed:@"icon_clock"];
    nextWaitImg.hidden = YES;
    [self addSubview:nextWaitImg];
    [_waitImgs addObject:nextWaitImg];
    _nextWaitImg = nextWaitImg;
    
    UILabel *nextCountLabel = [[UILabel alloc] initWithFrame:
                               CGRectMake(nextCardsView.x + nextCardsView.width / 2 - CountWidth / 2,
                                          nextCardsView.y + nextCardsView.height + 5,
                                          CountWidth,
                                          CountHeight)];
    nextCountLabel.textColor = [UIColor whiteColor];
    nextCountLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:nextCountLabel];
    [_countLabels addObject:nextCountLabel];
    _nextCountLabel = nextCountLabel;
    
    UILabel *nextPass = [[UILabel alloc] initWithFrame:
                         CGRectMake(nextPlayCardsView.x + nextPlayCardsView.width - 100,
                                    nextPlayCardsView.y + 50,
                                    100,
                                    30)];
    nextPass.textColor = [UIColor colorWithHexString:@"#d55351"];
    nextPass.font = [UIFont boldSystemFontOfSize:20];
    nextPass.textAlignment = NSTextAlignmentCenter;
    nextPass.hidden = YES;
    nextPass.text = @"不要";
    [self addSubview:nextPass];
    [_passLabels addObject:nextPass];
    _nextPassLabel = nextPass;
}

- (void)addLastCardView {
    CardsView *lastCardsView = [[CardsView alloc] initWithFrame:
                                CGRectMake(0,
                                           self.height * (1 - 2 * PlayCardsViewHeightRatio - CardsViewHeightRatio) - BtnHeight - BtnYSpace * 2,
                                           self.width * OtherCardViewWidthRatio,
                                           self.height * OtherCardViewHeightRatio
                                           )];
    [lastCardsView showBack];
    [self addSubview:lastCardsView];
    _lastCardsView = lastCardsView;
    
    CardsView *lastPlayCardsView = [[CardsView alloc] initWithFrame:
                                    CGRectMake(self.width * OtherCardViewWidthRatio + ClockSize,
                                               self.height * (1 - 2 * PlayCardsViewHeightRatio - CardsViewHeightRatio) - BtnHeight - BtnYSpace * 2,
                                               self.width * PlayCardsViewWidthRatio - ClockSize,
                                               self.height * PlayCardsViewHeightRatio)];
    [self addSubview:lastPlayCardsView];
    [_playCardViews addObject:lastPlayCardsView];
    _lastPlayCardsView = lastPlayCardsView;
    
    UIImageView *lastWaitImg = [[UIImageView alloc] initWithFrame:
                                CGRectMake(lastCardsView.x + lastCardsView.width,
                                           lastCardsView.y,
                                           ClockSize,
                                           ClockSize)];
    lastWaitImg.image = [UIImage imageNamed:@"icon_clock"];
    lastWaitImg.hidden = YES;
    [self addSubview:lastWaitImg];
    [_waitImgs addObject:lastWaitImg];
    _lastWaitImg = lastWaitImg;
    
    UILabel *lastCountLabel = [[UILabel alloc] initWithFrame:
                               CGRectMake(lastCardsView.x + lastCardsView.width / 2 - CountWidth / 2,
                                          lastCardsView.y + lastCardsView.height + 5,
                                          CountWidth,
                                          CountHeight)];
    lastCountLabel.textColor = [UIColor whiteColor];
    lastCountLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lastCountLabel];
    [_countLabels addObject:lastCountLabel];
    _lastCountLabel = lastCountLabel;
    
    UILabel *lastPass = [[UILabel alloc] initWithFrame:
                         CGRectMake(lastPlayCardsView.x,
                                    lastPlayCardsView.y + 50,
                                    100,
                                    30)];
    lastPass.textColor = [UIColor colorWithHexString:@"#d55351"];
    lastPass.font = [UIFont boldSystemFontOfSize:20];
    lastPass.textAlignment = NSTextAlignmentCenter;
    lastPass.hidden = YES;
    lastPass.text = @"不要";
    [self addSubview:lastPass];
    [_passLabels addObject:lastPass];
    _lastPassLabel = lastPass;
}

@end

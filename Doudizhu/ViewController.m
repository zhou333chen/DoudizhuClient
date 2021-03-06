//
//  ViewController.m
//  Doudizhu
//
//  Created by xiaotu on 2016/11/28.
//  Copyright © 2016年 personal. All rights reserved.
//

#import "ViewController.h"
#import "GameView.h"
#import "Card.h"
#import "SocketManager.h"
#import "BottomCardsView.h"
#import "Gamer.h"
#import "GamerChecker.h"

#define Host @"127.0.0.1"
#define Port 9527

typedef NS_ENUM(int, Operation) {
    OperationLogin = 1000,    //登录
    OperationDeal,  // 发牌
    OperationConfirm,   // 叫地主
    OperationPlay,  // 出牌 0张代表不要
    OperationPassLandlord,   // 不要地主
    OPerationIlligal    // 无效的操作
};

@interface ViewController ()<SocketDelegate>

@property (nonatomic, strong) Gamer *me;
@property (nonatomic, strong) Gamer *nextGamer;
@property (nonatomic, strong) Gamer *lastGamer;
@property (nonatomic, strong) Gamer *currentGamer;
@property (nonatomic, assign) int currentGamerIndex;
@property (nonatomic, strong) NSMutableArray *gamers;
@property (nonatomic, strong) SocketManager *socketManager;
@property (nonatomic, strong) GameView *gameView;
@property (nonatomic, assign) BOOL hasBegin;    // 是否已经叫完地主开始游戏了
@property (nonatomic, strong) NSArray *playCards;    // 当前轮次每个人出的牌

@end

@implementation ViewController

#pragma mark - init
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithHexString:@"#0d4d21"];
    _playCards = [NSArray arrayWithObjects:[[Cards alloc] init], [[Cards alloc] init], [[Cards alloc] init], nil];
    
    Gamer *me = [[Gamer alloc] init];
    me.user = [[User alloc] init];
    _me = me;
    
    me.user.userId = [NSString stringWithFormat:@"%d", arc4random() % 100];
    _gamers = [NSMutableArray array];
    [_gamers addObject:me];
    
    GameView *gameView = [[GameView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:gameView];
    [gameView.playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [gameView.passBtn addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
    _gameView = gameView;
    
    UIButton *restartBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 100, self.view.height - 100, 100, 50)];
    [restartBtn setTitle:@"重新开始" forState:UIControlStateNormal];
    [restartBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [restartBtn addTarget:self action:@selector(restart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:restartBtn];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    SocketManager *socketManager = [[SocketManager alloc] init];
    socketManager.delegate = self;
    [socketManager connectToHost:Host port:Port];
    _socketManager = socketManager;
}

#pragma mark - Click Event
- (void)play:(UIButton *)button {
    if (_hasBegin) {
        NSMutableArray *cards = _gameView.myCardsView.choosedCards.cardList;
        if (cards.count == 0) {
            return;
        }
        // 出的牌降序排列
        [cards sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            Card *card1 = obj1;
            Card *card2 = obj2;
            NSNumber *number1 = [NSNumber numberWithInt:card1.index];
            NSNumber *number2 = [NSNumber numberWithInt:card2.index];
            
            return [number2 compare:number1];
        }];
        // 牌型检查
        BOOL isIllegal = [GamerChecker checkCards:_gameView.myCardsView.choosedCards];
        if (!isIllegal) {
            return;
        }
        
        NSMutableString *cardsStr = [NSMutableString string];
        for (int i=0; i<cards.count; i++) {
            Card *card = cards[i];
            [cardsStr appendFormat:@"%d&", card.index];
        }
        
        [cardsStr deleteCharactersInRange:NSMakeRange(cardsStr.length - 1, 1)];
        [_socketManager writeString:[NSString stringWithFormat:@"%d|%@|%@", OperationPlay, _me.user.userId, cardsStr]];
    } else {
        [_socketManager writeString:[NSString stringWithFormat:@"%d|%@", OperationConfirm, _me.user.userId]];
    }
}

- (void)pass {
    if (_hasBegin) {
        [_socketManager writeString:[NSString stringWithFormat:@"%d|%@", OperationPlay, _me.user.userId]];
    } else {
        [_socketManager writeString:[NSString stringWithFormat:@"%d|%@", OperationPassLandlord, _me.user.userId]];
    }
}

- (void)restart {
    [_socketManager writeString:[NSString stringWithFormat:@"%d|%@", OperationLogin, _me.user.userId]];
}

#pragma mark - SocketDelegate
- (void)didConnect {
    NSLog(@"连接成功，正在登记玩家信息");
    [_socketManager writeString:[NSString stringWithFormat:@"%d|%@", OperationLogin, _me.user.userId]];
}

- (void)didReadString:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *strs = [string componentsSeparatedByString:@"|"];
        if (strs.count < 2) {
            return;
        }
        switch ([strs[0] intValue]) {
            case OperationDeal:
                [self getDealWithString:string];
                break;
            case OperationConfirm:
                [self getBottomWithString:string];
                break;
            case OperationPlay:
                [self getPlayWithString:string];
                break;
            case OperationPassLandlord:
                [self getPassLandlordWithString:string];
                break;
            case OPerationIlligal:
                [self getIllegalWithString:string];
                break;
            default:
                break;
        }
    });
}

- (void)didWriteString:(NSString *)string {
    
}

#pragma mark - analyse
- (void)getDealWithString:(NSString *)str {
    _hasBegin = NO;
    [_gameView reset];
    [_gamers removeObject:_lastGamer];
    [_gamers removeObject:_nextGamer];
    _lastGamer = nil;
    _nextGamer = nil;
    
    NSArray *strs = [str componentsSeparatedByString:@"|"];
    if (strs.count > 1) {
        [self getIds:strs[1]];
    }
    if (strs.count > 2) {
        [self getCards:strs[2]];
    }
}

- (void)getBottomWithString:(NSString *)str {
    NSArray *strs = [str componentsSeparatedByString:@"|"];
    if (strs.count == 3 && [strs[1] isEqualToString:_currentGamer.user.userId]) {
        _currentGamer.isLandlord = YES;
        _currentGamer.leftCount += 3;
        // 显示底牌
        NSMutableArray *bottomCards = [NSMutableArray array];
        NSArray *cardStr = [strs[2] componentsSeparatedByString:@"&"];
        for (int i=0; i<cardStr.count; i++) {
            int index = [cardStr[i] intValue];
            Card *card = [[Card alloc] init];
            card.index = index;
            [bottomCards addObject:card];
        }
        [_gameView.bottomCardsView setCards:bottomCards];
        
        _hasBegin = YES;
        // 显示出牌按钮或者“思考中”
        if (_currentGamer == _me) {
            [_me.cards.cardList addObjectsFromArray:bottomCards];
            [_me.cards.cardList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                Card *card1 = obj1;
                Card *card2 = obj2;
                NSNumber *number1 = [NSNumber numberWithInt:card1.index];
                NSNumber *number2 = [NSNumber numberWithInt:card2.index];
                
                return [number2 compare:number1];

            }];
            [_gameView.myCardsView setCards:_me.cards clickable:YES];
            [_gameView setLandlord:LandlordMe];
        } else {
            UILabel *countLabel = _gameView.countLabels[_currentGamerIndex];
            countLabel.text = [NSString stringWithFormat:@"%d", _currentGamer.leftCount];
            
            int index = (int)[_gamers indexOfObject:_me];
            if ((index + 1) % 3 == _currentGamerIndex) {
                [_gameView setLandlord:LandlordNext];
            } else {
                [_gameView setLandlord:LandlordLast];
            }
        }
        [_gameView.playBtn setTitle:@"出牌" forState:UIControlStateNormal];
    }
}

- (void)getPlayWithString:(NSString *)str {
    NSArray *strs = [str componentsSeparatedByString:@"|"];
    if (strs.count >= 2 && [strs[1] isEqualToString:_currentGamer.user.userId]) {
        Cards *cards = [[Cards alloc] init];
        NSMutableArray *playCards = cards.cardList;
        if (strs.count == 3) {
            // 出牌
            NSArray *cardStr = [strs[2] componentsSeparatedByString:@"&"];
            for (int i=0; i<cardStr.count; i++) {
                int index = [cardStr[i] intValue];
                Card *card = [[Card alloc] init];
                card.index = index;
                [playCards addObject:card];
            }
        } else {
            // 不要
            if (playCards.count == 0) {
                UILabel *passLabel = _gameView.passLabels[_currentGamerIndex];
                passLabel.hidden = NO;
            }
        }
        Cards *currentPlayCards = _playCards[_currentGamerIndex];
        currentPlayCards.cardList = playCards;
        _currentGamer.leftCount -= (int)playCards.count;
        // 如果我刚出完牌，则隐藏按钮
        if (_currentGamer == _me) {
            [_me.cards.cardList removeObjectsInArray:playCards];
            [_gameView.myCardsView setCards:_me.cards clickable:YES];
            _gameView.passBtn.hidden = YES;
            _gameView.playBtn.hidden = YES;
        }
        // 隐藏当前玩家的倒计时
        UIImageView *waitView = _gameView.waitImgs[_currentGamerIndex];
        if ([waitView isKindOfClass:[UIImageView class]]) {
            waitView.hidden = YES;
        }
        // 显示出的牌
        CardsView *cardsView = _gameView.playCardViews[_currentGamerIndex];
        [cardsView setCards:cards clickable:NO];
        // 显示剩余牌数
        UILabel *countLabel = _gameView.countLabels[_currentGamerIndex];
        if ([countLabel isKindOfClass:[UILabel class]]) {
            countLabel.text = [NSString stringWithFormat:@"%d", _currentGamer.leftCount];
        }
        // 游戏结束
        if (_currentGamer.leftCount == 0) {
            if (_currentGamer == _me || _currentGamer.isLandlord == _me.isLandlord) {
                [SVProgressHUD showInfoWithStatus:@"你赢了"];
                NSLog(@"win");
            } else {
                [SVProgressHUD showInfoWithStatus:@"你输了"];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self restart];
            });
        }
        
        _currentGamerIndex = (_currentGamerIndex + 1) % 3;
        _currentGamer = _gamers[_currentGamerIndex];
        
        // 如果其他人都要不起下家的牌，则清空牌面
        if ([_playCards[_currentGamerIndex] cardList].count > 0 &&
            [_playCards[(_currentGamerIndex + 1) % 3] cardList].count == 0 &&
            [_playCards[(_currentGamerIndex + 2) % 3] cardList].count == 0) {
            for (UIView *view in _gameView.passLabels) {
                if ([view respondsToSelector:@selector(setHidden:)]) {
                    view.hidden = YES;
                }
            }
        }
        // 如果下一个是我出牌，则显示按钮
        if (_currentGamer == _me) {
            _gameView.passBtn.hidden = NO;
            _gameView.playBtn.hidden = NO;
        } else {
            UIImageView *waitView = _gameView.waitImgs[_currentGamerIndex];
            if ([waitView isKindOfClass:[UIImageView class]]) {
                waitView.hidden = NO;
            }
        }
        // 隐藏上一轮我出的牌
        CardsView *playCardView = _gameView.playCardViews[_currentGamerIndex];
        [playCardView setCards:nil clickable:NO];
        
        UILabel *passLabel2 = _gameView.passLabels[_currentGamerIndex];
        passLabel2.hidden = YES;
    }
}

- (void)getPassLandlordWithString:(NSString *)str {
    NSArray *strs = [str componentsSeparatedByString:@"|"];
    if (strs.count == 2) {
        [self setLandlord:strs[1]];
    }
}

- (void)getIllegalWithString:(NSString *)str {
    NSArray *strs = [str componentsSeparatedByString:@"|"];
    if (strs.count == 2 && [strs[1] isEqualToString:_currentGamer.user.userId]) {
        [SVProgressHUD showErrorWithStatus:@"你的牌太小了！"];
    }
}

- (void)getIds:(NSString *)str {
    NSArray *ids = [str componentsSeparatedByString:@"&"];
    
    if (ids.count == 4) {
        _me.leftCount = 17;
        
        Gamer *lastGamer = [[Gamer alloc] init];
        lastGamer.leftCount = 17;
        lastGamer.user = [[User alloc] init];
        lastGamer.user.userId = ids[1];
        UILabel *label = _gameView.countLabels[1];
        label.text = [NSString stringWithFormat:@"%d", lastGamer.leftCount];
        [_gamers addObject:lastGamer];
        _lastGamer = lastGamer;
        
        Gamer *nextGamer = [[Gamer alloc] init];
        nextGamer.leftCount = 17;
        nextGamer.user = [[User alloc] init];
        nextGamer.user.userId = ids[2];
        label = _gameView.countLabels[2];
        label.text = [NSString stringWithFormat:@"%d", lastGamer.leftCount];
        [_gamers addObject:nextGamer];
        _nextGamer = nextGamer;
        
        NSString *currentId = ids[3];
        [self setLandlord:currentId];
    }
}

- (void)getCards:(NSString *)str {
    NSArray *strs = [str componentsSeparatedByString:@"&"];
    Cards *cards = [[Cards alloc] init];
    NSMutableArray *cardList = cards.cardList;
    for (int i=0; i<strs.count; i++) {
        Card *card = [[Card alloc] init];
        card.index = [strs[i] intValue];
        [cardList addObject:card];
    }
    
    [cardList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Card *card1 = obj1;
        Card *card2 = obj2;
        NSNumber *number1 = [NSNumber numberWithInt:card1.index];
        NSNumber *number2 = [NSNumber numberWithInt:card2.index];
        
        return [number2 compare:number1];
    }];
    _me.cards.cardList = cardList;
    [_gameView.myCardsView setCards:_me.cards clickable:YES];
}

- (void)setLandlord:(NSString *)userId {
    for (int i=0; i<3; i++) {
        Gamer *gamer = _gamers[i];
        if ([gamer.user.userId isEqualToString:userId]) {
            _currentGamer = gamer;
            _currentGamerIndex = i;
            break;
        }
    }
    
    _gameView.playBtn.hidden = YES;
    _gameView.passBtn.hidden = YES;
    for (UIView *view in _gameView.waitImgs) {
        if ([view respondsToSelector:@selector(setHidden:)]) {
            view.hidden = YES;
        }
    }

    if (_currentGamer == _me) {
        _gameView.playBtn.hidden = NO;
        _gameView.passBtn.hidden = NO;
        [_gameView.playBtn setTitle:@"叫地主" forState:UIControlStateNormal];
    } else {
        UIView *view = _gameView.waitImgs[[_gamers indexOfObject:_currentGamer]];
        view.hidden = NO;
    }
}

@end

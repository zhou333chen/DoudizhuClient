//
//  CardsView.h
//  Doudizhu
//
//  Created by xiaotu on 2016/11/28.
//  Copyright © 2016年 personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cards.h"

@interface CardsView : UIView

@property (nonatomic, strong) Cards *choosedCards;

- (void)setCards:(Cards *)cards clickable:(BOOL)clickable;
- (void)showBack;

@end

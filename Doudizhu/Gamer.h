//
//  Gamer.h
//  Doudizhu
//
//  Created by xiaotu on 2016/11/30.
//  Copyright © 2016年 personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Cards.h"

@interface Gamer : NSObject

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Cards *cards;
@property (nonatomic, assign) int cardsCount;
@property (nonatomic, assign) BOOL isLandlord;

@end

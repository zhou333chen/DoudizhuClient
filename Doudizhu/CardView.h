//
//  CardView.h
//  Doudizhu
//
//  Created by xiaotu on 2016/11/28.
//  Copyright © 2016年 personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

#define OVERLAY_RATIO 0.7
#define BasicWidth 5.7
#define BasicHeight 8.8

@interface CardView : UIButton

@property (nonatomic, strong) Card *card;
@property (nonatomic, assign) BOOL isChoosed;
@property (nonatomic, assign) BOOL isRevearsed;

@end

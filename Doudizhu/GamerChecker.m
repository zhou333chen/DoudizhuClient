//
//  GamerChecker.m
//  Doudizhu
//
//  Created by xiaotu on 2016/12/1.
//  Copyright © 2016年 personal. All rights reserved.
//

#import "GamerChecker.h"

@implementation GamerChecker

+ (BOOL)checkCards:(Cards *)cards {
    if ([self checkKingBomb:cards] ||
        [self checkNormalBomb:cards] ||
        [self checkStraight:cards] ||
        [self checkPlane:cards] ||
        [self checkFour:cards] ||
        [self checkThree:cards] ||
        [self checkDouble:cards] ||
        [self checkSingle:cards]) {
        NSString *str;
        switch (cards.type) {
            case TypeKingBomb:
                str = @"王炸";
                break;
            case TypeNormalBomb:
                str = @"普通炸";
                break;
            case TypeStraight:
                str = @"顺子";
                break;
            case TypeCompany:
                str = @"连队";
                break;
            case TypePlane:
                str = @"飞机";
                break;
            case TypeFour:
                str = @"四带二";
                break;
            case TypeThree:
                str = @"三带";
                break;
            case TypeDouble:
                str = @"对子";
                break;
            case TypeSingle:
                str = @"单张";
                break;
            default:
                break;
        }
        NSLog(@"牌型：%@", str);
        return YES;
    } else {
        cards.type = TypeIllegal;
        NSLog(@"牌型不合法");
        return NO;
    }
}

+ (BOOL)checkKingBomb:(Cards *)cards {
    if (cards.count == 2 &&
        [cards.cardList[0] index] == 53 &&
        [cards.cardList[1] index] == 54) {
        cards.type = TypeKingBomb;
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)checkNormalBomb:(Cards *)cards {
    if (cards.count == 4) {
        for (int i=0; i<3; i++) {
            if ([cards.cardList[i] number] != [cards.cardList[i+1] number]) {
                return NO;
            }
        }
        cards.type = TypeNormalBomb;
        return YES;
    }
    return NO;
}

+ (BOOL)checkStraight:(Cards *)cards {
    if (cards.count >= 5) {
        for (int i=0; i<cards.count-1; i++) {
            if ([cards.cardList[i] number] != [cards.cardList[i+1] number]+1) {
                return NO;
            }
        }
        cards.type = TypeStraight;
        return YES;
    }
    return NO;
}

+ (BOOL)checkCompany:(Cards *)cards {
    if (cards.count >= 6 && cards.count % 2 == 0) {
        for (int i=0; i<cards.count; i=i+2) {
            if ([cards.cardList[i] number] != [cards.cardList[i+1] number] ||
                (i < cards.count - 2 && [cards.cardList[i] number] != [cards.cardList[i+2] number] - 1)) {
                return NO;
            }
        }
        cards.type = TypeCompany;
        return YES;
    }
    return NO;
}

+ (BOOL)checkPlane:(Cards *)cards {
    if (cards.count >= 6) {
        int planeCount = 0;
        int flag = 0;   // 1代表相同的牌在前面，2代表相同的牌在后面
        for (int i=0; i<=cards.count-3; i=i+3) {

            if ([cards.cardList[i] number] == [cards.cardList[i+1] number] &&
                [cards.cardList[i] number] == [cards.cardList[i+2] number]) {
                planeCount++;
                flag = 1;
            } else {
                break;
            }
        }
        if (planeCount == 0) {
            for (int i=cards.count-1; i>=2; i=i-3) {
                if ([cards.cardList[i] number] == [cards.cardList[i-1] number] &&
                    [cards.cardList[i] number] == [cards.cardList[i-2] number]) {
                    planeCount++;
                    flag = 2;
                } else {
                    break;
                }

            }
        }
        // 判断飞机带的牌是否符合要求
        if (planeCount > 0) {
            int index;
            if (flag == 1) {
                index = planeCount * 3;
            } else {
                index = 0;
            }
            if (cards.count == planeCount * 3) {
                // 不带牌
                cards.type = TypePlane;
                return YES;
            } else if (cards.count == planeCount * 4) {
                // 三带一
                cards.type = TypePlane;
                if (flag == 2) {
                    [self adjustOrder:cards atIndex:planeCount];
                }
                return YES;
            } else if (cards.count == planeCount * 5){
                // 三带二
                for (; index<planeCount*2; index=index+2) {
                    if ([cards.cardList[index] number] != [cards.cardList[index+1] number]) {
                        return NO;
                    }
                }
                cards.type = TypePlane;
                if (flag == 2) {
                    [self adjustOrder:cards atIndex:planeCount * 2];
                }
                return YES;
            }
        }
    }
    return NO;
}

+ (BOOL)checkFour:(Cards *)cards {
    if (cards.count == 6 || cards.count == 8) {
        int flag = 0;   // 1代表四张在前面，2代表四张在后面
        [cards.cardList[0] number];
        if ([cards.cardList[0] number] == [cards.cardList[1] number] &&
            [cards.cardList[0] number] == [cards.cardList[2] number] &&
            [cards.cardList[0] number] == [cards.cardList[3] number]) {
            flag = 1;
        } else if ([cards.cardList[cards.count-1] number] == [cards.cardList[cards.count-2] number] &&
                   [cards.cardList[cards.count-1] number] == [cards.cardList[cards.count-3] number] &&
                   [cards.cardList[cards.count-1] number] == [cards.cardList[cards.count-4] number]) {
            flag = 2;
        } else {
            return NO;
        }
        int index;
        if (flag == 1) {
            index = 4;
        } else {
            index = 0;
        }
        if (cards.count == 6) {
            cards.type = TypeFour;
            if (flag == 2) {
                [self adjustOrder:cards atIndex:2];
            }
            return YES;
        } else if (cards.count == 8) {
            if ([cards.cardList[index] number] == [cards.cardList[index+1] number] &&
                [cards.cardList[index+2] number] == [cards.cardList[index+3] number]) {
                cards.type = TypeFour;
                if (flag == 2) {
                    [self adjustOrder:cards atIndex:4];
                }
                return YES;
            }
        }
    }
    return NO;
}

+ (BOOL)checkThree:(Cards *) cards {
    if (cards.count >= 3 && cards.count <=5) {
        int flag = 0;   // 1代表飞机在前面，2代表飞机在后面
        if ([cards.cardList[0] number] == [cards.cardList[1] number] &&
            [cards.cardList[0] number] == [cards.cardList[2] number]) {
            flag = 1;
        } else if ([cards.cardList[cards.count-1] number] == [cards.cardList[cards.count-2] number] &&
                   [cards.cardList[cards.count-1] number] == [cards.cardList[cards.count-3] number]) {
            flag = 2;
        } else {
            return NO;
        }
        int index;
        if (flag == 1) {
            index = 3;
        } else {
            index = 0;
        }
        if (cards.count == 3) {
            cards.type = TypeThree;
            return YES;
        } else if (cards.count == 4){
            cards.type = TypeThree;
            if (flag == 2) {
                [self adjustOrder:cards atIndex:1];
            }
            return YES;
        } else {
            if ([cards.cardList[index] number] == [cards.cardList[index+1] number]) {
                cards.type = TypeThree;
                if (flag == 2) {
                    [self adjustOrder:cards atIndex:2];
                }
                return YES;
            } else {
                return NO;
            }
        }
    }
    return NO;
}

+ (BOOL)checkDouble:(Cards *)cards {
    if (cards.count == 2) {
        if ([cards.cardList[0] number] == [cards.cardList[1] number]) {
            cards.type = TypeDouble;
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

+ (BOOL)checkSingle:(Cards *)cards {
    if (cards.count == 1) {
        cards.type = TypeSingle;
        return YES;
    }
    return NO;
}

// AB->BA
+ (void)adjustOrder:(Cards *)cards atIndex:(int)index {
    if (index > cards.count - 1) {
        return;
    }
    for (int i=0; i<index; i++) {
        Card *card = [cards.cardList objectAtIndex:0];
        [cards.cardList removeObject:card];
        [cards.cardList addObject:card];
    }
}

@end

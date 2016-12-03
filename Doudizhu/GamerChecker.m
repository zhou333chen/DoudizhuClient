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
        [SVProgressHUD showErrorWithStatus:@"这牌型不对吧！"];
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
        int firstIndex = -1;
        for (int i = 0; i<cards.count - planeCount * 2; i++) {
            if ([cards.cardList[i] number] == [cards.cardList[i+1] number] &&
                [cards.cardList[i] number] == [cards.cardList[i+2] number]) {
                if (firstIndex == -1) {
                    firstIndex = i;
                }
                i += 2;
                planeCount++;
            } else if (firstIndex != -1){
                return false;
            }
        }
        // 判断飞机带的牌是否符合要求
        if (planeCount > 0) {
            if (cards.count == planeCount * 3) {
                // 不带牌
                cards.type = TypePlane;
                return YES;
            } else if (cards.count == planeCount * 4) {
                // 三带一
                [self adjustCards:cards toFrontfromIndex:firstIndex toIndex:firstIndex + planeCount * 3];
                cards.type = TypePlane;
                return YES;
            } else if (cards.count == planeCount * 5){
                // 三带二
                for (int i=0; i<firstIndex; i= i + 2) {
                    if ([cards.cardList[i] number] != [cards.cardList[i+1] number]) {
                        return NO;
                    }
                }
                for (int i=firstIndex + planeCount * 3; i<cards.count; i=i + 2) {
                    if ([cards.cardList[i] number] != [cards.cardList[i+1] number]) {
                        return NO;
                    }
                }
                [self adjustCards:cards toFrontfromIndex:firstIndex toIndex:firstIndex + planeCount * 3];
                cards.type = TypePlane;
                return YES;
            }
        }
    }
    return NO;
}

+ (BOOL)checkFour:(Cards *)cards {
    if (cards.count == 6 || cards.count == 8) {
        int firstIndex = -1;
        for (int i = 0; i<=cards.count - 4; i++) {
            if ([cards.cardList[i] number] == [cards.cardList[i+1] number] &&
                [cards.cardList[i] number] == [cards.cardList[i+2] number] &&
                [cards.cardList[i] number] == [cards.cardList[i+3] number]) {
                firstIndex = i;
                break;
            }
        }
        if (firstIndex == -1) {
            return false;
        }
        if (cards.count == 6) {
            [self adjustCards:cards toFrontfromIndex:firstIndex toIndex:firstIndex + 4];
            cards.type = TypeFour;
            return YES;
        } else if (cards.count == 8) {
            for (int i=0; i<firstIndex; i=i + 2) {
                if ([cards.cardList[i] number] != [cards.cardList[i+1] number]) {
                    return NO;
                }
            }
            for (int i=firstIndex + 4; i<cards.count; i=i + 2) {
                if ([cards.cardList[i] number] != [cards.cardList[i+1] number]) {
                    return NO;
                }
            }
            [self adjustCards:cards toFrontfromIndex:firstIndex toIndex:firstIndex + 4];
            return YES;
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
                [self adjustCards:cards toFrontfromIndex:1 toIndex:4];
            }
            return YES;
        } else {
            if ([cards.cardList[index] number] == [cards.cardList[index+1] number]) {
                cards.type = TypeThree;
                if (flag == 2) {
                    [self adjustCards:cards toFrontfromIndex:2 toIndex:5];
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
+ (void)adjustCards:(Cards *)cards toFrontfromIndex:(int)from toIndex:(int)to{
    if (from == 0) {
        return;
    }
    
    if (from > cards.count - 1 || to > cards.count - 1) {
        return;
    }
    
    for (int i=from; i<to; i++) {
        Card *card = [cards.cardList objectAtIndex:i];
        [cards.cardList removeObject:card];
        [cards.cardList insertObject:card atIndex:0];
    }
}

@end

//
//  SocketManager.h
//  Doudizhu
//
//  Created by xiaotu on 2016/11/28.
//  Copyright © 2016年 personal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SocketDelegate <NSObject>

@optional
- (void)didConnect;
- (void)didReadString:(NSString *)string;
- (void)didWriteString:(NSString *)string;

@end

@interface SocketManager : NSObject

@property (nonatomic, strong) id<SocketDelegate> delegate;

- (void)connectToHost:(NSString *)host port:(int)port;
- (void)writeString:(NSString *)string;

@end

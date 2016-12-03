//
//  SocketManager.m
//  Doudizhu
//
//  Created by xiaotu on 2016/11/28.
//  Copyright © 2016年 personal. All rights reserved.
//

#import "SocketManager.h"
#import "GCDAsyncSocket.h"
#import "CocoaAsyncSocket.h"

@interface SocketManager()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSMutableDictionary *writeStrings;
@property (nonatomic, assign) long tag;

@end

@implementation SocketManager

- (void)connectToHost:(NSString *)host port:(int)port {
    GCDAsyncSocket *socket=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)];
    [socket connectToHost:host onPort:port error:nil];
    [socket readDataWithTimeout:-1 tag:1];
    _socket = socket;
    
    _writeStrings = [NSMutableDictionary dictionary];
    _tag = 0;
}

- (void)writeString:(NSString *)string {
    [_writeStrings setValue:string forKey:[NSString stringWithFormat:@"%ld", _tag]];
    string = [NSString stringWithFormat:@"%@\r\n", string];
    NSLog(@"write: %@", string);
    [_socket writeData:[string dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:_tag++];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"connect");
    if ([_delegate respondsToSelector:@selector(didConnect)]) {
        [_delegate didConnect];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_socket readDataWithTimeout:-1 tag:-1];
    NSLog(@"reveive: %@", str);
    if ([_delegate respondsToSelector:@selector(didReadString:)]) {
        str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [_delegate didReadString:str];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if ([_delegate respondsToSelector:@selector(didWriteString:)]) {
        [_delegate didWriteString:_writeStrings[[NSString stringWithFormat:@"%ld", tag]]];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"disconnect");
}


@end

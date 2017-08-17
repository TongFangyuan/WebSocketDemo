//
//  ViewController.m
//  WebSocketDemo
//
//  Created by tongfy on 17/6/30.
//  Copyright © 2017年 PaPaQuan. All rights reserved.
//

#import "ViewController.h"
#import <SRWebSocket.h>

@interface ViewController ()
<
SRWebSocketDelegate
>

@property (nonatomic, strong) SRWebSocket *socket;
@property (weak, nonatomic) IBOutlet UITextView *outputView;

@property (weak, nonatomic) IBOutlet UIButton *openButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

- (IBAction)connectAction:(id)sender;
- (IBAction)closedConnectAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.closeButton.enabled = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SRWebSocket *)socket
{
    if (!_socket) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ws.weiya.in:7272/"]];
        _socket = [[SRWebSocket alloc] initWithURLRequest:request];
        _socket.delegate = self;
    }
    return _socket;
}

- (IBAction)connectAction:(id)sender
{
    self.openButton.enabled = NO;
    [self.socket open];
}
- (IBAction)closedConnectAction:(id)sender
{
    [self.socket close];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    [self outputString:message type:1];
    NSLog(@"%@",message);
    
    NSError *jsonError;
    NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *msgDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
    NSString *type = msgDict[@"type"];
    if ([type isEqualToString:@"ping"]) {
        [self.socket send:@"{\"type\":\"pong\"}"];
        [self outputString:@"{\"type\":\"pong\"}" type:2] ;
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"连接成功webSocketDidOpen:%@",webSocket);
    [self outputString:[NSString stringWithFormat:@"连接成功webSocketDidOpen:%@",webSocket] type:1];
    [self outputString:[NSString stringWithFormat:@"连接地址:%@",webSocket.url.absoluteString] type:1];
    self.closeButton.enabled = YES;
    
    // 连接上之后,发送登录信息
//    {"type":"login","uid":"1","topic_id":"bhy7zsa1f9"}
    [self.socket send:@"{\"type\":\"login\",\"uid\":\"1\",\"topic_id\":\"bhy7zsa1f9\"}"];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"连接失败: %@",error);
    [self outputString:[NSString stringWithFormat:@"连接失败: %@",error] type:1];
    self.socket.delegate = nil;
    self.socket =nil;
    [self.socket close];
    self.openButton.enabled = YES;
    self.closeButton.enabled = NO;
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    self.openButton.enabled = YES;
    self.socket.delegate = nil;
    self.socket =nil;
    NSLog(@"didCloseWithCode:%ldreason:%@wasClean:%d",(long)code,reason,wasClean);
    [self outputString:[NSString stringWithFormat:@"didCloseWithCode:%ld\nreason:%@\nwasClean:%d",(long)code,reason,wasClean] type:1];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    NSLog(@"webSocketdidReceivePong:%@",pongPayload);
    [self outputString:[NSString stringWithFormat:@"webSocketdidReceivePong:%@",pongPayload] type:1];
}

- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket
{
    NSLog(@"webSocketShouldConvertTextFrameToString:%@",webSocket);
    return YES;
}

/** type:1接收 2发送 */
- (void)outputString:(NSString *)str type:(NSInteger)type
{
    NSString *prefix = type==1 ? @"接收" : @"发送";
    str = [NSString stringWithFormat:@"%@:%@",prefix,str];
    NSString *text;
    if (self.outputView.text.length>0) {
        text = [NSString stringWithFormat:@"%@\n%@",self.outputView.text,str];
    } else {
        text = [NSString stringWithFormat:@"%@",str];
    }
    self.outputView.text = text;
}

@end

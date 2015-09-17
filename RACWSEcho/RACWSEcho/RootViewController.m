// RootViewController.m
// Copyright (c) 2015 Dmitry Lizin (sdkdimon@gmail.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RootViewController.h"
#import "RACSRWebSocket.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

static NSString * const WS_URL = @"ws://echo.websocket.org";

@interface RootViewController () <UITextFieldDelegate,RACSRWebSocketMessageTransformer>
@property (weak, nonatomic) IBOutlet UIButton *clearLogButton;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *diconnectButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property(strong,nonatomic,readwrite) RACSRWebSocket *wsClient;

@end

@implementation RootViewController
@synthesize wsClient = _wsClient;

-(void)setupBindings{
    [_connectButton addTarget:self action:@selector(connect:) forControlEvents:UIControlEventTouchUpInside];
    [_diconnectButton addTarget:self action:@selector(disconnect:) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [_clearLogButton addTarget:self action:@selector(clearLog) forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self clearLog];
    [self setupBindings];
}

#pragma mark UIActions

-(void)connect:(UIButton *)sender{
    [[[self wsClient] openConnection] subscribeNext:^(id x) {
        NSLog(@"connected");
    }];
}

-(void)disconnect:(UIButton *)sender{
    @weakify(self);
    [[[self wsClient] closeConnection] subscribeNext:^(id x) {
        @strongify(self);
         NSLog(@"disconnected");
        [self setWsClient:nil];
    }];
}

-(void)send:(UIButton *)sender{
    NSString *textMessage = [_messageTextField text];
    if([textMessage length] > 0) {[[[self wsClient] sendDataCommand] execute:textMessage];}
}

-(RACSRWebSocket *)wsClient{
    
    if(_wsClient == nil){
        _wsClient = [[RACSRWebSocket alloc] initWithURL:[NSURL URLWithString:WS_URL]];
        [_wsClient setMessageTransformer:self];
        [self subscribeOnWebSocketEvents];
    }
    return _wsClient;
}

-(void)subscribeOnWebSocketEvents{
    @weakify(self);
    
    [[_wsClient webSocketDidCloseSignal] subscribeNext:^(id x) {
        @strongify(self);
        [self logMessage:@"Connection did close."];
    }];
    
    [[_wsClient webSocketDidOpenSignal] subscribeNext:^(id x) {
        @strongify(self);
        [self logMessage:@"Connection did open."];
    }];
    
    [[_wsClient webSocketDidReceiveMessageSignal] subscribeNext:^(RACTuple *args) {
        @strongify(self);
        [self logMessage:@"Receive message:"];
        [self logMessage:[args second]];
    }];
    
}

-(void)logMessage:(NSString *)message{
    NSString *logText = [_logTextView text];
    if(logText != nil && [logText length] > 0){
        NSString *newLogText = [NSString stringWithFormat:@"%@\n%@",logText,message];
        [_logTextView setText:newLogText];
        return;
    }
    [_logTextView setText:message];
}

-(void)clearLog{
    [_logTextView setText:nil];
}

#pragma mark RACSRWebSocketMessageTransformer

-(NSString *)websocket:(RACSRWebSocket *)websocket transformRequestMessage:(NSString *)message{
    return [message stringByAppendingString:@"transformRequestMessage"];
}

-(NSString *)websocket:(RACSRWebSocket *)websocket transformResponseMessage:(id)message{
    return [message stringByAppendingString:@"transformResponseMessage"];
}

#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end

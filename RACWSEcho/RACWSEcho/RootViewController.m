//
//  ViewController.m
//  RACWSEcho
//
//  Created by dimon on 08/09/15.
//
//

#import "RootViewController.h"
#import "RACSRWebSocket.h"
#import "IncomingMessageTransformer.h"
#import "OutgoingMessageTransformer.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

static NSString * const WS_URL = @"ws://echo.websocket.org";

@interface RootViewController () <UITextFieldDelegate>
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
        [self subscribeOnWebSocketEvents];
        [_wsClient setIncomingMessageTransformer:[[IncomingMessageTransformer alloc] init]];
        [_wsClient setOutgoingMessageTransformer:[[OutgoingMessageTransformer alloc] init]];

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

#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end

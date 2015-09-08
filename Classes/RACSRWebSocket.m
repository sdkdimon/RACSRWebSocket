
#import "RACSRWebSocket.h"
#import <ReactiveCocoa/RACSubject.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/RACCompoundDisposable.h>
#import <ReactiveCocoa/RACTuple.h>

@interface RACSRWebSocket() <SRWebSocketDelegate>

@property(strong,nonatomic,readwrite) RACSubject *webSocketDidOpenSubject;
@property(strong,nonatomic,readwrite) RACSubject *webSocketDidReceiveMessageSubject;
@property(strong,nonatomic,readwrite) RACSubject *webSocketDidFailSubject;
@property(strong,nonatomic,readwrite) RACSubject *webSocketDidCloseSubject;
@property(strong,nonatomic,readwrite) RACSubject *webSocketDidReceivePongSubject;


@end


@implementation RACSRWebSocket


-(id)initWithURL:(NSURL *)url{
    if((self = [super initWithURL:url]) != nil){
        [self initialize];
    }
    return self;
}


-(void)initialize{
     [self setDelegate:self];
    _webSocketDidOpenSignal = _webSocketDidOpenSubject = [RACSubject subject];
    _webSocketDidReceiveMessageSignal = _webSocketDidReceiveMessageSubject = [RACSubject subject];
    _webSocketDidFailSignal = _webSocketDidFailSubject = [RACSubject subject];
    _webSocketDidCloseSignal = _webSocketDidCloseSubject = [RACSubject subject];
    _webSocketDidReceivePongSignal = _webSocketDidReceivePongSubject = [RACSubject subject];
    
    @weakify(self);
    _sendDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id data) {
       @strongify(self);
        RACSignal *sendDataSignal = [[self openConnection] flattenMap:^RACStream *(id value) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [self send:data];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
        return sendDataSignal;
    }];
    [_sendDataCommand setAllowsConcurrentExecution:YES];
}


-(void)send:(id)data{
    if(_outgouingMessageTransformerBlock){
        data = _outgouingMessageTransformerBlock(data);
    }
    NSLog(@"\n");
    NSLog(@"//=======================================");
    NSLog(@"webSocket will send data: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"//=======================================");
    NSLog(@"\n");
    [super send:data];
}

-(RACSignal *)openConnection{
    @weakify(self);
    return [self readyState] == SR_CONNECTING ?
        [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            RACDisposable *openSignalDisposable = [[self webSocketDidOpenSignal] subscribeNext:^(id x) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }];
            RACDisposable *failSignalDisposable = [[self webSocketDidFailSignal] subscribeNext:^(RACTuple *args) {
                [subscriber sendError:[args second]];
            }];
            [self open];
            return [RACCompoundDisposable compoundDisposableWithDisposables:@[openSignalDisposable,failSignalDisposable]];
        }] : [RACSignal return:nil];
    
  
}



#pragma mark - SRWebSocketDelegate

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"\n");
    NSLog(@"//=======================================");
    NSLog(@"webSocket didReceiveMessage: %@",message);
    NSLog(@"//=======================================");
    NSLog(@"\n");
    if(_incomingMessageTransformerBlock){
        message = _incomingMessageTransformerBlock(message);
    }
    
    RACTuple *args = [RACTuple tupleWithObjects:webSocket,message,nil];
    [_webSocketDidReceiveMessageSubject sendNext:args];
}

-(void)webSocketDidOpen:(SRWebSocket *)webSocket{
    RACTuple *args = [RACTuple tupleWithObjects:webSocket,nil];
    [_webSocketDidOpenSubject sendNext:args];
}

-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    RACTuple *args = [RACTuple tupleWithObjects:webSocket,@(code),reason,@(wasClean),nil];
    [_webSocketDidCloseSubject sendNext:args];
}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    RACTuple *args = [RACTuple tupleWithObjects:webSocket,error,nil];
    [_webSocketDidFailSubject sendNext:args];
}

-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    RACTuple *args = [RACTuple tupleWithObjects:webSocket,pongPayload,nil];
    [_webSocketDidReceivePongSubject sendNext:args];
}





@end

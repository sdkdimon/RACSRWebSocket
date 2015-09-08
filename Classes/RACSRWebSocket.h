
#import <SocketRocket/SRWebSocket.h>
#import <ReactiveCocoa/RACSignal.h>
#import <ReactiveCocoa/RACCommand.h>

typedef id (^WSMessageTransformerBlock)(id message);

@interface RACSRWebSocket : SRWebSocket

@property(weak,nonatomic,readonly) RACSignal *webSocketDidOpenSignal;
@property(weak,nonatomic,readonly) RACSignal *webSocketDidReceiveMessageSignal;
@property(weak,nonatomic,readonly) RACSignal *webSocketDidFailSignal;
@property(weak,nonatomic,readonly) RACSignal *webSocketDidCloseSignal;
@property(weak,nonatomic,readonly) RACSignal *webSocketDidReceivePongSignal;

@property(strong,nonatomic,readonly) RACCommand *sendDataCommand;

/**
 *  Tramsformer block for incoming usages, to simplify data convertation.
 */
@property(copy,nonatomic,readwrite) WSMessageTransformerBlock incomingMessageTransformerBlock;
@property(copy,nonatomic,readwrite) WSMessageTransformerBlock outgouingMessageTransformerBlock;

-(RACSignal *)openConnection;

@end

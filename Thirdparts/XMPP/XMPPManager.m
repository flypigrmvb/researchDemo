//
//  XMPPManager.m
//  SpartaEducation
//
//  Created by kiwi on 14-7-21.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "XMPPManager.h"
#import "Message.h"
#import "KWAlertView.h"
#import "JSON.h"
#import "AppDelegate.h"
#import "BSEngine.h"
#import "KWAlertView.h"

static XMPPManager * shareXMPPManager;

@interface XMPPManager ()  {
    XMPPStream      * xmppStream;
    XMPPReconnect   * xmppReconnect;
	BOOL            allowSelfSignedCertificates;
	BOOL            allowSSLHostNameMismatch;
	BOOL            isXmppConnected;
    NSTimeInterval  lastConnect;
    BOOL            connecting;
}

@end

@implementation XMPPManager
@synthesize userId, password;
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize roomsDic;

+ (XMPPManager*)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareXMPPManager = [[XMPPManager alloc] init];
    });
    return shareXMPPManager;
}

#pragma mark Private

- (void)goOnline {
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	[[self xmppStream] sendElement:presence];
    [[AppDelegate instance] startSetOnline];
}

- (void)goOffline {
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	[[self xmppStream] sendElement:presence];
}

- (BOOL)exist {
    return xmppStream?YES:NO;
}

#pragma mark Connect/disconnect

- (BOOL)connectAgain {
    if (!connecting && [NSDate timeIntervalSinceReferenceDate] - lastConnect > 5 && !xmppStream.isAuthenticated) {
        [self connectWithId:userId password:password];
        return YES;
    }
    return NO;
}

- (void)disconnect {
	[self goOffline];
	[xmppStream disconnect];
    connecting = NO;
    lastConnect = [NSDate timeIntervalSinceReferenceDate];
}

- (BOOL)connectWithId:(NSString*)name password:(NSString*)pass {
    userId = name;
    password = pass;
    connecting = YES;
    if (![xmppStream isDisconnected]) {
		return YES;
	}
    NSString * myJID = [NSString stringWithFormat:@"%@@%@/%@", userId, KBSSDKAPIDomainXMPPServer, KBSSDKAPIDomainXMPPServer];
    
	if (myJID == nil || password == nil) {
		return NO;
	}
    DLog(@"Try to connect to [Chat server]");
    //    DLog(@"发送连接请求 JID:%@",myJID);
	[xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    
	NSError *error = nil;
	if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        DLog(@"Error connecting: %@", error);
		return NO;
	}
	return YES;
}

#pragma mark - xmppStream

- (void)setupStream {
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
	xmppStream = [[XMPPStream alloc] init];
	xmppReconnect = [[XMPPReconnect alloc] init];
	[xmppReconnect activate:xmppStream];

	[xmppStream addDelegate:self delegateQueue:kQueueMain];
	
	[xmppStream setHostName:KBSSDKAPIDomainXMPP];
	[xmppStream setHostPort:KBSSDKAPIDomainXMPPPort];
	
	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
}

- (void)teardownStream {
	[xmppStream removeDelegate:self];
	[xmppReconnect deactivate];
	[xmppStream disconnect];
	xmppStream = nil;
	xmppReconnect = nil;
}

#pragma mark XMPP receiptMessage

- (void)receiptMessageID:(NSString*)mid {
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"receipt"];
    [message addAttributeWithName:@"id" stringValue:mid];
    XMPPIQ* iq = [XMPPIQ iqWithType:@"set" child:message];
    [[self xmppStream] sendElement:iq];
}

#pragma mark XMPPStream Delegate

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DLog(@"%s",__func__);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DLog(@"%s",__func__);
    if (allowSelfSignedCertificates)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
#pragma clang diagnostic pop
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    DLog(@"%s",__func__);
}

// 连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DLog(@"%s",__func__);
	isXmppConnected = YES;
	NSError * error = nil;
    // 验证密码
	if (![[self xmppStream] authenticateWithPassword:password error:&error]) {
        connecting = NO;
        lastConnect = [NSDate timeIntervalSinceReferenceDate];
        [self disconnect];
		DLog(@"Error authenticating: %@", error);
	}
}

// 验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DLog(@"Chat System online");
    connecting = NO;
    lastConnect = [NSDate timeIntervalSinceReferenceDate];
    //    DLog(@"%s",__func__);
	[self goOnline];
}

// 验证未通过
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    connecting = NO;
    lastConnect = [NSDate timeIntervalSinceReferenceDate];
    [self disconnect];
    [[[KWAlertView alloc] initWithTitle:nil message:@"登录已经失效, 请重新登录！" delegate:self cancelButtonTitle:nil otherButtonTitle:@"重新登录"] show];
    DLog(@"Chat Server authentication failure!");
}

- (void)kwAlertView:(KWAlertView*)sender didDismissWithButtonIndex:(NSInteger)index {
    [[AppDelegate instance] signOut];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DLog(@"%s",__FUNCTION__);
	return NO;
}

// 收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    //    DLog(@"%s",__FUNCTION__);
    NSString * dataString = [[message elementForName:@"body"] stringValue];
    if (!dataString) {
        return;
    }
    
    NSString * from = [message attributeStringValueForName:@"from"];
	NSDictionary * result = [JSON mutableObjectFromJSONString:dataString];

	if (![result isKindOfClass:[NSDictionary class]]) {
        DLog(@"消息结构体不正确: %@", dataString);
        return;
	}
    
    [[AppDelegate instance] didReceiveMessage:result from:from receiptMessageID:[message attributeStringValueForName:@"id"]];
}

// 收到好友状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    //    DLog(@"%s",__func__);
    //    DLog(@"presence = %@", presence);
    NSXMLElement *x = [presence elementForName:@"x" xmlns:@"http://jabber.org/protocol/muc#user"];
    for (NSXMLElement *status in [x elementsForName:@"status"])
    {
        switch ([status attributeIntValueForName:@"code"])
        {
            case 201:
                DLog(@"got 201");
                break;
        }
    }
    //取得好友状态
    NSString *presenceType = [presence type]; //online/offline
    //当前用户
    NSString *currectUserId = [[sender myJID] user];
    //在线用户
    NSString *presenceFromUser = [[presence from] user];
    if (![presenceFromUser isEqualToString:currectUserId]) {
        //在线状态
        if ([presenceType isEqualToString:@"available"]) {
            DLog(@"%@ online",presenceFromUser);
        }else if ([presenceType isEqualToString:@"unavailable"]) {
            DLog(@"%@ offline",presenceFromUser);
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error {
    DLog(@"%s",__func__);
    DLog(@"%@",error);
    BOOL isConflict = NO;
    
    if (error != nil && [error isKindOfClass:[NSXMLElement class]]) {
        NSXMLElement* tmpStream = (NSXMLElement*)error;
        NSXMLElement* tmpConflict = [tmpStream elementForName:@"conflict"];
        if (tmpConflict) {
            [[AppDelegate instance] signOutWithConflict];
        }
    }
    if (!isConflict) {
        [self connectAgain];
    }
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    DLog(@"%s",__func__);
//    DLog(@"%@",error);
	if (!isXmppConnected) {
        DLog(@"Unable to connect to server. Please check your network status.");
	}
}

@end

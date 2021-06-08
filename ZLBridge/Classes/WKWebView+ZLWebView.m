//
//  WKWebView+ZLWebView.m
//  ZLBridge
//
//  Created by 范鹏 on 2021/6/4.
//

#import "WKWebView+ZLWebView.h"
#import <objc/runtime.h>
@implementation ZLUtils
+ (NSString *)objToJsonString:(id)dict
{
    NSString *jsonString = nil;
    NSError *error;
    if (![NSJSONSerialization isValidJSONObject:dict]) return @"{}";
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (!jsonData) return @"{}";
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
+ (id )jsonStringToObject:(NSString *)jsonString
{
    if (jsonString == nil) return nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) return nil;
    return dic;
}
@end
//////
//////
@implementation ZLMsgBody
+ (instancetype)initMsgBodyWithDic:(NSDictionary*)dic{
    ZLMsgBody *obj = [[ZLMsgBody alloc] init];
    obj.name = dic[@"name"];
    obj.body = dic[@"body"];
    obj.callID = dic[@"callID"];
    obj.end = [NSString stringWithFormat:@"%@",dic[@"end"]];
    obj.jsMethodId = dic[@"jsMethodId"];
    return obj;
}
@end
/////////////////////
////////////////////
@implementation ZLBridge
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSDictionary *body = message.body;
    ZLMsgBody *obj = [ZLMsgBody initMsgBodyWithDic:body];
    if (self.msgCallback) self.msgCallback(obj);
}
@end
/////////////////////
////////////////////
@implementation WKWebView (ZLWebView)
static const char JSCompletionHandlersKey = '\0';
- (void)setRegistHanders:(NSMutableDictionary<NSString *,JSRegistHandler> *)registHanders {
    objc_setAssociatedObject(self, &JSCompletionHandlersKey,
                             registHanders,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary<NSString*,JSRegistHandler> *)registHanders {
    NSMutableDictionary *dic = objc_getAssociatedObject(self, &JSCompletionHandlersKey);
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
        self.registHanders = dic;
    }
    return dic;
}

static const char JSCallHandlersKey = '\0';
- (void)setCallHanders:(NSMutableDictionary<NSString *,JSCompletionHandler> *)callHanders {
    objc_setAssociatedObject(self, &JSCallHandlersKey,
                             callHanders,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary<NSString*,JSCompletionHandler> *)callHanders {
    NSMutableDictionary *dic = objc_getAssociatedObject(self, &JSCallHandlersKey);
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
        self.callHanders = dic;
    }
    return dic;
}
- (void)initBridgeWithLocalJS:(BOOL )localJs{
    if (localJs) {
        NSBundle *selfBundle = [NSBundle bundleForClass:ZLBridge.class];
        NSString *path = [selfBundle pathForResource:@"ZLBridge.bundle/index.js" ofType:nil];
        NSData *data=[NSData dataWithContentsOfFile:path];
        NSString *js =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        WKUserScript *jsScript = [[WKUserScript alloc] initWithSource:js
                                              injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                           forMainFrameOnly:YES];
        [self.configuration.userContentController addUserScript:jsScript];
    }
    
    ZLBridge *bridge = [[ZLBridge alloc] init];
    __weak typeof(self) weakSelf = self;
    bridge.msgCallback = ^(ZLMsgBody * _Nonnull message) {
        NSString *name = message.name;
        NSString *callID = message.callID;
        NSString *end = message.end;
        id body = message.body;
        if (callID) {
           JSCompletionHandler callHandler = weakSelf.callHanders[callID];
            if (callHandler) {
                callHandler(body,nil);
                if ([end isKindOfClass:NSString.class] && [end isEqualToString:@"1"]) {
                    [weakSelf.callHanders removeObjectForKey:callID];
                }
            }
            return;
        }
        NSString *jsMethodId = message.jsMethodId;
        JSRegistHandler registHandler = weakSelf.registHanders[name];
        JSCallbackHandler callBack =  ^(id result,BOOL end){
            NSMutableDictionary *mDic = NSMutableDictionary.dictionary;
            mDic[@"end"] = end?@1:@0;
            mDic[@"result"] = result?result:@"";
            NSString *js = [NSString stringWithFormat:@"window.ZLBridge._nativeCallback('%@','%@');",jsMethodId,[ZLUtils objToJsonString:mDic]];
            [weakSelf evaluateJavaScript:js completionHandler:nil];
        };
        if (registHandler) registHandler(body,callBack);
    };
    [self.configuration.userContentController addScriptMessageHandler:bridge name:@"ZLBridge"];
}
- (void)destroyBridge{
    [self.registHanders removeAllObjects];
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"ZLBridge"];
}
-(void) registHandler:(NSString * _Nonnull) methodName  completionHandler:(JSRegistHandler _Nonnull) registHandler{
    if (![methodName isKindOfClass:NSString.class] || !registHandler) return;
    self.registHanders[methodName] = registHandler;
}
-(void)callHandler:(NSString * _Nonnull) methodName  completionHandler:(JSCompletionHandler _Nonnull)completionHandler{
    [self callHandler:methodName arguments:nil completionHandler:completionHandler];
}
-(void)callHandler:(NSString * _Nonnull) methodName  arguments:(NSArray * _Nullable) args completionHandler:(JSCompletionHandler _Nonnull)completionHandler{
    args = args == nil ? @[] : args;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (args) dic[@"result"] = args;
    NSString *ID;
    if (completionHandler) {
        ID = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        dic[@"callID"] = ID;
        self.callHanders[ID] = completionHandler;
    }
    NSString *js = [NSString stringWithFormat:@"window.ZLBridge._nativeCall('%@','%@');",methodName,[ZLUtils objToJsonString:dic]];
    __weak typeof(self) weakSelf = self;
    [self evaluateJavaScript:js completionHandler:^(NSDictionary* _Nullable obj, NSError * _Nullable error) {
        if (error) {
            if (completionHandler) completionHandler(nil,error);
            [weakSelf.callHanders removeObjectForKey:ID];
        }else {
            if ([obj isKindOfClass:NSDictionary.class]) {
                NSString *sync = obj[@"sync"];
                id result = obj[@"result"];
                if ([sync isEqual:NSString.class] && sync.boolValue) {
                    [weakSelf.callHanders removeObjectForKey:ID];
                }
                if (completionHandler) completionHandler(result,nil);
            }
        }
    }];
}
- (void)hasNativeMethod:(NSString * _Nonnull)methodName callback:(void(^ _Nullable)(BOOL exist))callback;{
    if (!callback) return;
    if (methodName == nil || methodName.length == 0 ) {
        callback(NO);
        return;
    }
    NSString *js = [NSString stringWithFormat:@"window.ZLBridge._hasNativeMethod('%@');",methodName];
    [self evaluateJavaScript:js completionHandler:^(NSNumber * _Nullable obj, NSError * _Nullable error) {
        if (error) {
            callback(NO);
        }else {
            callback(obj.boolValue);
        }
    }];
}
@end

//
//  WKWebView+ZLWebView.h
//  ZLBridge
//
//  Created by 范鹏 on 2021/6/4.
//

#import <WebKit/WebKit.h>
typedef void (^JSCompletionHandler)(id _Nullable obj, NSError * _Nullable error);
typedef void (^JSCallbackHandler)(id _Nullable obj, BOOL end);
typedef void (^JSRegistHandler)(id _Nullable obj,JSCallbackHandler _Nullable callback);
NS_ASSUME_NONNULL_BEGIN
@interface ZLUtils : NSObject
+ (NSString * _Nullable)objToJsonString:(id  _Nonnull)dict;
+ (id  _Nullable)jsonStringToObject:(NSString * _Nonnull)jsonString;
@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface ZLMsgBody : NSObject
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *jsMethodId;
@property (nonatomic,strong)id body;
+ (instancetype)initMsgBodyWithDic:(NSDictionary*)dic;
@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface ZLBridge : NSObject<WKScriptMessageHandler>
@property (nonatomic,copy)void(^msgCallback)(ZLMsgBody *message);
@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface WKWebView (ZLWebView)
//初始化bridge的时候是否本地注入js
- (void)initBridgeWithLocalJS:(BOOL )localJs;
//需要手动移除bridge，否则会内存泄漏
- (void)destroyBridge;
//注册原生方法供js调用
-(void) registHandler:(NSString * _Nonnull) methodName  completionHandler:(JSRegistHandler _Nonnull) registHandler;
//原生调用js
-(void) callHandler:(NSString * _Nonnull) methodName  completionHandler:(JSCompletionHandler _Nonnull)completionHandler;
//原生调用js传参数
-(void) callHandler:(NSString * _Nonnull) methodName  arguments:(NSArray * _Nullable) args completionHandler:(JSCompletionHandler _Nonnull)completionHandler;
//js是否注册了原生调用的方法
- (void)hasNativeMethod:(NSString * _Nonnull)methodName callback:(void(^ _Nullable)(BOOL exist))callback;
@end
NS_ASSUME_NONNULL_END

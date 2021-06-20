//
//  ZLViewController.m
//  ZLBridge
//
//  Created by 范鹏 on 06/04/2021.
//  Copyright (c) 2021 范鹏. All rights reserved.
//
#import "ZLViewController.h"
#import <WebKit/WebKit.h>
#import <WKWebView+ZLBridge.h>
#import "ZLTextVC.h"
@interface ZLViewController ()<WKUIDelegate>
@property (strong, nonatomic)  WKWebView *wkwebView;
@property (strong,nonatomic)NSTimer *timer;
@end
@implementation ZLViewController
- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(viewDidLoad) userInfo:nil repeats:YES];
    }
    return _timer;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
    [self.wkwebView initBridgeWithLocalJS:YES];
    self.wkwebView.UIDelegate = self;
    NSString *path = [NSBundle.mainBundle pathForResource:@"index.html" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
//    url = [NSURL URLWithString:@"http://localhost:3000/"];
    [self.wkwebView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:self.wkwebView];
    [self.wkwebView registHandler:@"test" completionHandler:^(id  _Nullable obj, JSCallbackHandler  _Nullable callback) {
        callback(obj,YES);
    }];
    [self.wkwebView registUndefinedHandler:^(NSString * _Nullable name, id  _Nullable obj, JSCallbackHandler  _Nullable callback) {
        NSLog(@"registUndefinedHandlerCompletionHandler:%@",name);
    }];
    [self.wkwebView registHandler:@"upload" completionHandler:^(id  _Nullable obj, JSCallbackHandler  _Nullable callback) {
        [self uploadCompletionHandler:callback];
    }];
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    completionHandler();
}
#pragma mark - 原生主动调用js
- (IBAction)calljs:(UIButton*)sender {
    [self.wkwebView callHandler:@"jsMethod" arguments:@[@"这是原生调用js传的值"] completionHandler:^(id  _Nullable obj, NSString * _Nullable error) {
        NSString *msg;
        if (error) {
            msg = error;
        }else {
            msg = [obj isKindOfClass:NSString.class] ? obj : [ZLUtils objToJsonString:obj];
        }
        [sender setTitle: msg forState:UIControlStateNormal];
    }];
}
- (void)uploadCompletionHandler:(JSCallbackHandler _Nullable)completionHandler {
    __block int i = 0;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        i += 1;
        BOOL end = i == 10;
        NSString *str = end ? @"上传完成" : [NSString stringWithFormat:@"%d%%",i*10];
        completionHandler(str,end);
    }];
}
- (IBAction)refresh:(id)sender {
    [self.wkwebView reload];
}
- (IBAction)jsAction1:(id)sender {
    [self.wkwebView callHandler:@"jsMethod" completionHandler:^(id  _Nullable obj, NSString * _Nullable error) {
        NSString *msg = error ? error : @"成功调用JS事件1";
        [sender setTitle:msg forState:UIControlStateNormal];
    }];
}
- (IBAction)jsAction2:(UIButton*)sender {
    [self.wkwebView callHandler:@"jsMethodWithCallback" arguments:nil completionHandler:^(id  _Nullable obj, NSString * _Nullable error) {
        NSString *msg = error ? error : @"成功调用JS事件2";
        [sender setTitle:msg forState:UIControlStateNormal];
    }];
}
- (void)dealloc
{
    [self.wkwebView destroyBridge];
}
@end

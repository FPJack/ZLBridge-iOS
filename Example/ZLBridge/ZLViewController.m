//
//  ZLViewController.m
//  ZLBridge
//
//  Created by 范鹏 on 06/04/2021.
//  Copyright (c) 2021 范鹏. All rights reserved.
//
#import "ZLViewController.h"
#import <WebKit/WebKit.h>
#import <ZLBridge/WKWebView+ZLWebView.h>
#import "ZLTextVC.h"
@interface ZLViewController ()
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
    NSString *path = [NSBundle.mainBundle pathForResource:@"index.html" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self.wkwebView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:self.wkwebView];
    [self.wkwebView registHandler:@"test" completionHandler:^(id  _Nullable obj, JSCallbackHandler  _Nullable callback) {
        callback(@"js异步调用：这是原生返回的结果1000！",YES);
    }];
    [self.wkwebView registHandler:@"upload" completionHandler:^(id  _Nullable obj, JSCallbackHandler  _Nullable callback) {
        [self uploadCompletionHandler:callback];
    }];
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
- (IBAction)nextVC:(id)sender {
    [self.navigationController pushViewController:ZLTextVC.new animated:YES];
}
- (void)dealloc
{
    [self.wkwebView destroyBridge];
}
@end

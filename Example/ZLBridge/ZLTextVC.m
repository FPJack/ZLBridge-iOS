//
//  ZLTextVC.m
//  ZLBridge_Example
//
//  Created by 范鹏 on 2021/6/4.
//  Copyright © 2021 范鹏. All rights reserved.
//

#import "ZLTextVC.h"
#import <WebKit/WebKit.h>
#import <ZLBridge/WKWebView+ZLWebView.h>
#import "ZLWebview.h"
@interface ZLTextVC ()
@property (strong, nonatomic)  WKWebView *wkwebView;
@property (strong,nonatomic)NSTimer *timer;
@end
@implementation ZLTextVC
- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(viewDidLoad) userInfo:nil repeats:YES];
    }
    return _timer;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wkwebView = [[ZLWebview alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
    [self.wkwebView initBridgeWithLocalJS:YES];
    NSString *path = [NSBundle.mainBundle pathForResource:@"index.html" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self.wkwebView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:self.wkwebView];
    __weak typeof(self) weakSelf = self;

    [self.wkwebView registHandler:@"test" completionHandler:^(id  _Nullable obj, JSCallbackHandler  _Nullable callback) {
        callback(@"js异步调用：这是原生返回的结果1000！",NO);
    }];
    [self.wkwebView registHandler:@"upload" completionHandler:^(id  _Nullable obj, JSCallbackHandler  _Nullable callback) {
        [weakSelf uploadCompletionHandler:callback];
    }];
}
#pragma mark - 原生主动调用js
- (IBAction)calljs:(UIButton*)sender {
    [self.wkwebView callHandler:@"jsMethod" arguments:@[@"这是原生主动调用js原生传给js的值，js原封不动把值返回"] completionHandler:^(id  _Nullable obj, NSError * _Nullable error) {
        NSLog(@"%@",obj);
        NSString *msg = [obj isKindOfClass:NSString.class] ? obj : [ZLUtils objToJsonString:obj];
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

@end

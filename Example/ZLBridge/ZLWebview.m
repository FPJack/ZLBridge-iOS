//
//  ZLWebview.m
//  ZLBridge_Example
//
//  Created by 范鹏 on 2021/6/4.
//  Copyright © 2021 范鹏. All rights reserved.
//

#import "ZLWebview.h"
#import <objc/runtime.h>
#import <WKWebView+ZLWebView.h>
@implementation ZLWebview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)dealloc
{
    NSLog(@"webview已销毁");
}

@end

# ZLBridge

[![CI Status](https://img.shields.io/travis/范鹏/ZLBridge.svg?style=flat)](https://travis-ci.org/范鹏/ZLBridge)
[![Version](https://img.shields.io/cocoapods/v/ZLBridge.svg?style=flat)](https://cocoapods.org/pods/ZLBridge)
[![License](https://img.shields.io/cocoapods/l/ZLBridge.svg?style=flat)](https://cocoapods.org/pods/ZLBridge)
[![Platform](https://img.shields.io/cocoapods/p/ZLBridge.svg?style=flat)](https://cocoapods.org/pods/ZLBridge)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ZLBridge is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZLBridge'
```
# 初始化
```objective-c
[self.wkwebView initBridgeWithLocalJS:YES];
```
## js调用原生


### 原生注册test事件
```objective-c
[self.wkwebView registHandler:@"test" completionHandler:^(id  _Nullable obj, JSCallbackHandler  _Nullable callback) {
    callback(@"js异步调用：这是原生返回的结果1000！",YES);
}];
```
### js调用test

#### 无参数
```JavaScript
window.ZLBridge.call('test',(arg) => {

});
```
#### 有参数参数
```JavaScript
window.ZLBridge.call('test',{key:"value"},(arg) => {

});
```



## 原生调用js
### js注册jsMethod方法
```JavaScript
window.ZLBridge.register("jsMethod",(arg) => {
     return arg;
 });
 ```
### 原生调用jsMethod
```objective-c
[self.wkwebView callHandler:@"jsMethod" arguments:@[@"这是原生调用js传的值"] completionHandler:^(id  _Nullable obj, NSError * _Nullable error) {
}];
```

# 移除ZLBridge
```objective-c
[self.wkwebView destroyBridge];
```
## Author

范鹏, 2551412939@qq.com



## License

ZLBridge is available under the MIT license. See the LICENSE file for more info.

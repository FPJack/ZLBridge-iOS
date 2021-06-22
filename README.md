# ZLBridge

[![CI Status](https://img.shields.io/travis/范鹏/ZLBridge.svg?style=flat)](https://travis-ci.org/范鹏/ZLBridge)
[![Version](https://img.shields.io/cocoapods/v/ZLBridge.svg?style=flat)](https://cocoapods.org/pods/ZLBridge)
[![License](https://img.shields.io/cocoapods/l/ZLBridge.svg?style=flat)](https://cocoapods.org/pods/ZLBridge)
[![Platform](https://img.shields.io/cocoapods/p/ZLBridge.svg?style=flat)](https://cocoapods.org/pods/ZLBridge)

## 说明
ZLBridge是为iOS的WKWebview和JS数据交互时提供更简单方便的小工具组件,可配合H5端使用ZLBridge-JS库来数据交互，也可选择原生本地注入JS代码，H5无需任何集成操作。目前已支持的平台有
<br/>[ZLBridge-iOS](https://github.com/FPJack/ZLBridge-iOS)
<br/>[ZLBridge-Android](https://github.com/FPJack/ZLBridge-Android)
<br/>[ZLBridge-JS](https://github.com/FPJack/ZLBridge-JS)
<br/>[ZLBridge-flutter](https://github.com/FPJack/ZLBridge-flutter)
<br/>[ZLBridge-RN](https://github.com/FPJack/ZLBridge-RN)

## 安装
```ruby
//如果安装失败，pod update更新一下
pod 'ZLBridge'
```
## H5端window.zlbridge初始化
```objective-c
#import <ZLBridge/WKWebView+ZLBridge.h>

//YES：原生注入本地js脚本初始化zlbridge，NO：由H5初始化zlbridge
[self.wkwebView initBridgeWithLocalJS:YES];
```
H5初始化zlbridge
```JavaScript
 //导入一次后也可以通过window.zlbridge拿zlbridge对象
 var zlbridge = require('zlbridge')
```
## 原生与JS交互


### JS调用原生test事件

#### 无参数
```JavaScript
window.zlbridge.call('test',(arg) => {

});
```
#### 有参数参数
```JavaScript
window.zlbridge.call('test',{key:"value"},(arg) => {

});
```
#### 原生注册test事件
```objective-c
[self.wkwebView registHandler:@"test" completionHandler:^(id  _Nullable obj, JSCallbackHandler  _Nullable callback) {
    //YES代表JS只能监听一次回调结果，NO可以连续监听
    callback(@"js异步调用：这是原生返回的结果1000！",YES);
}];
```


### 原生调用js

#### 原生调用JS的jsMethod事件
```objective-c
[self.wkwebView callHandler:@"jsMethod" arguments:@[@"这是原生调用js传的值"] completionHandler:^(id  _Nullable obj, NSError * _Nullable error) {
}];
```

#### js注册jsMethod事件
```JavaScript
window.zlbridge.register("jsMethod",(arg) => {
     return arg;
 });
 ```
 或者
 ```JavaScript
 window.zlbridge.registerWithCallback("jsMethod",(arg,callback) => {
    //ture代表原生只能监听一次回调结果，false可以连续监听，默认传为true
     callback(arg,true);
  });
  ```

## 通过本地注入JS脚本的，H5可以监听ZLBridge初始化完成
```JavaScript
document.addEventListener('ZLBridgeInitReady', function() {
    consloe.log('ZLBridge初始化完成');
},false);
  ```
  
## 移除ZLBridge
```objective-c
[self.wkwebView destroyBridge];
```
## !!! iOS传给JS的值需支持放入字典里面可以NSJSONSerialization的对象
## Author

范鹏, 2551412939@qq.com



## License

ZLBridge is available under the MIT license. See the LICENSE file for more info.

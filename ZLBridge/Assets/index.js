 (function () {
     var ZLBridge = {
         //异步调用原生方法，支持promise和函数回调
         call: function(method,arg,func){
             // if (window._ZLBridgeInitInit !== true) return;
             var _callHandlerID = setTimeout(function(){});
             _callHandlerID = "_methodid_" + _callHandlerID;
             if (typeof arg == 'function') {
                 func = arg;
                 arg = null;
             }
             var args = {};
             args["jsMethodId"] = _callHandlerID ;
             args["body"] = arg;
             args["name"] = method;
             if (typeof func == "function") {
                 window.ZLBridge[_callHandlerID] = func;
                 window.ZLBridge._callNative(args);
             }
         },
         //注册原生回调的方法
         register: function(method,func){
             if (typeof func == "function" && typeof method == "string") {
                 window.ZLBridge["_register_" + method] = func;
             }
         },
         registerWithCallback: function(method,func){
             if (typeof func == "function" && typeof method == "string") {
                 window.ZLBridge["_register_callback" + method] = func;
             }
         },
         _callNative: function(arg) {
             window.webkit.messageHandlers.ZLBridge.postMessage(arg);
         },
         //原生异步回调
         _nativeCallback: function(methodid,arg){
             var func = window.ZLBridge[methodid];
             if (typeof func != "function") return;
             arg = JSON.parse(arg);
             func(arg["result"]);
             if (arg.end==1) delete window.ZLBridge[methodid];
         },
         //原生主动调用
         _nativeCall: function(method,arg) {
             var obj = JSON.parse(arg);
             var result = obj["result"];
             var func = window.ZLBridge["_register_" + method];
             if (typeof func == "function") {
                 var funcResult = func(result);
                 return {sync:true,result:funcResult};
             }
             func = window.ZLBridge["_register_callback" + method];
             var callID = obj["callID"];
             var callback = function (params,end) {
                 var args = {};
                 if (callID) args["callID"] = callID ;
                 args["body"] = params;
                 args["end"] = (typeof end == "boolean")?end:true;
                 window.ZLBridge._callNative(args);
             }
             func(result,callback);
         },
         //是否注册了原生方法
         _hasNativeMethod: function(method) {
             var func = window.ZLBridge["_register_" + method]
             if (typeof func != "function") func = window.ZLBridge["_register_callback" + method];
             return (func!=null||func!=undefined);
         }
     }
     window.ZLBridge = ZLBridge;
 })();

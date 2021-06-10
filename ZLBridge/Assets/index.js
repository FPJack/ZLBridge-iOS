(function () {
    if (window.ZLBridge) return;
    var ZLBridge = {
        call: function(method,arg,func){
            if (typeof method != 'string') return;
            if (typeof arg == 'function') {
                func = arg;
                arg = null;
            }
            var args = {};
            args['body'] = arg;
            args['name'] = method;
            args['end'] = true;
            args['callID'] = '';
            if (typeof func == 'function') {
                var _callHandlerID = setTimeout(function(){});
                _callHandlerID = '_methodid_' + _callHandlerID;
                args['jsMethodId'] = _callHandlerID ;
                window.ZLBridge[_callHandlerID] = func;
            }
            window.ZLBridge._callNative(args);
        },
         _callNative: function(arg) {
               if(window.androidBridge && window.androidBridge.messageHandlers){
                  window.androidBridge.messageHandlers(JSON.stringify(arg));
               }else if (window.webkit && window.webkit.messageHandlers){
                  window.webkit.messageHandlers.ZLBridge.postMessage(JSON.stringify(arg));
               }
          },
        register: function(method,func){
            if (typeof func == 'function' && typeof method == 'string') {
                window.ZLBridge['_register_' + method] = func;
            }
        },
        registerWithCallback: function(method,func){
            if (typeof func == 'function' && typeof method == 'string') {
                window.ZLBridge['_register_callback' + method] = func;
            }
        },
        _nativeCall: function(method,arg) {
            var obj = JSON.parse(arg);
            var result = obj['result'];
            var callID = obj['callID'];
            setTimeout(() => {
                  try {
                       var func = window.ZLBridge['_register_' + method];
                       if (typeof func == 'function') {
                           var args = {};
                           args['end'] = true;
                           if (callID) args['callID'] = callID;
                           args['body'] = func(result);
                           return window.ZLBridge._callNative(args);
                       }
                       func = window.ZLBridge['_register_callback' + method];
                       var callback = function (params,end) {
                           var args = {};
                           if (callID) args['callID'] = callID;
                           args['body'] = params;
                           args['end'] = (typeof end == 'boolean')?end:true;
                           window.ZLBridge._callNative(args);
                       };
                       func(result,callback);
                     } catch (error) {
                       console.log(error);
                       window.ZLBridge._callNative({error:error.message,callID:callID,end:true});
                  }
           });
        },
        _nativeCallback: function(methodid,arg){
            setTimeout(() => {
               var func = window.ZLBridge[methodid];
               if (typeof func != 'function') return;
               arg = JSON.parse(arg);
               func(arg['result']);
               if (arg.end==1) delete window.ZLBridge[methodid];
            });
        },
        _hasNativeMethod: function(method) {
            var func = window.ZLBridge['_register_' + method];
            return (func!=null||func!=undefined);
        }
    };
    window.ZLBridge = ZLBridge;
    var doc = document;
    var event = doc.createEvent('Events');
    event.initEvent('ZLBridgeInitReady');
    doc.dispatchEvent(event);
})();

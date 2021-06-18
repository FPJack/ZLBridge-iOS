(function () {
    if (window.zlbridge) return ;
    var zlbridge = {
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
                _callHandlerID = '_methodid_' + _callHandlerID + new Date().getTime();
                args['jsMethodId'] = _callHandlerID ;
                window.zlbridge[_callHandlerID] = func;
            }
            window.zlbridge._callNative(args);
        },
         _callNative: function(arg) {
               if(window.ZLBridge && window.ZLBridge.postMessage){
                  window.ZLBridge.postMessage(JSON.stringify(arg));
               }else if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.ZLBridge){
                  window.webkit.messageHandlers.ZLBridge.postMessage(JSON.stringify(arg));
               }
          },
        register: function(method,func){
            if (typeof func == 'function' && typeof method == 'string') {
                window.zlbridge['_register_' + method] = func;
            }
        },
        removeRegisted: function(method) {
            if (typeof method != 'string') return;
            delete window.zlbridge['_register_' + method];
            delete window.zlbridge['_register_callback' + method];
         },
        registerWithCallback: function(method,func){
            if (typeof func == 'function' && typeof method == 'string') {
                window.zlbridge['_register_callback' + method] = func;
            }
        },
        _nativeCall: function(method,arg) {
            var obj = JSON.parse(arg);
            var result = obj['result'];
            var callID = obj['callID'];
            setTimeout(() => {
                  try {
                       var func = window.zlbridge['_register_' + method];
                       if (typeof func == 'function') {
                           var args = {};
                           args['end'] = true;
                           if (callID) args['callID'] = callID;
                           args['body'] = func(result);
                           return window.zlbridge._callNative(args);
                       }
                       func = window.zlbridge['_register_callback' + method];
                       var callback = function (params,end) {
                           var args = {};
                           if (callID) args['callID'] = callID;
                           args['body'] = params;
                           args['end'] = (typeof end == 'boolean')?end:true;
                           window.zlbridge._callNative(args);
                       };
                       func(result,callback);
                     } catch (error) {
                       window.zlbridge._callNative({error:error.message,callID:callID,end:true});
                  }
           });
        },
        _nativeCallback: function(methodid,arg){
            setTimeout(() => {
               var func = window.zlbridge[methodid];
               if (typeof func != 'function') return;
               arg = JSON.parse(arg);
               func(arg['result']);
               if (arg.end==1) delete window.zlbridge[methodid];
            });
        },
        _hasNativeMethod: function(method) {
            var func = window.zlbridge['_register_' + method];
            if (typeof func != "function")func = window.zlbridge['_register_callback' + method];
            return (func!=null||func!=undefined);
        }
    };
    window.zlbridge = zlbridge;
    var doc = document;
    var event = doc.createEvent('Events');
    event.initEvent('ZLBridgeInitReady');
    doc.dispatchEvent(event);
})();

(function () {
    var ZLBridge = {
        call: function(method,arg,func){
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
        register: function(method,func){
            if (typeof func == "function" && typeof method == "string") {
                window.ZLBridge["_register_" + method] = func;
            }
        },
        _callNative: function(arg) {
            window.webkit.messageHandlers.ZLBridge.postMessage(arg);
        },
        _nativeCallback: function(methodid,arg){
            var func = window.ZLBridge[methodid];
            if (typeof func != "function") return;
            arg = JSON.parse(arg);
            func(arg["result"]);
            if (arg.end==1) delete window.ZLBridge[methodid]; 
        },
        _nativeCall: function(method,arg) {
            var func = window.ZLBridge["_register_" + method];
            return arg?func(JSON.parse(arg)["result"]):func();
        },
        _hasNativeMethod: function(method) {
            var func = window.ZLBridge["_register_" + method]
            return (func!=null||func!=undefined);
        }
    }
    window.ZLBridge = ZLBridge;
})();

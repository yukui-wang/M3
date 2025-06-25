(function(){

    var canConnectNative = true;
    var ua = navigator.userAgent.toLowerCase();
    if(ua.indexOf("like mac os x") > 0){
        var reg = /os [\d._]*/gi ;
        var verinfo = ua.match(reg) ;
        var version = (verinfo+"").replace(/[^0-9|_.]/ig,"").replace(/_/ig,".");
        var arr=version.split(".");
        if (arr && arr.length > 0){
            var f = arr[0], s = arr[1];
            if (f>9){
                canConnectNative = true;
            }
        }
        _cmpJsConsole('os version info:',version);
    }
    _cmpJsConsole('canConnectNative:',canConnectNative);

    function _cmpJsConsole(action,param){//打日志到原生进行记录
//       var result = window.localStorage[ "isDev" ];
//       if (result === "1") {
           var actionParams = {
               method:"cmpJsConsole",
               from:window.location.href,
               action,
               param
           }
           var r = prompt.apply(window, [ JSON.stringify(actionParams) ]);
           return r;
//       }
    }
    function _cmpJsVerify(condition,param,key){//打日志到原生进行记录
        //       var result = window.localStorage[ "isDev" ];
        //       if (result === "1") {
                   var actionParams = {
                       method:"verify",
                       from:window.location.href,
                       condition,
                       param,
                       key
                   }
                   var r = prompt.apply(window, [ JSON.stringify(actionParams) ]);
                   _cmpJsConsole('_cmpJsVerify ret value' + r);
                   return r;
        //       }
            }
    window.onerror = function(sMsg,sUrl,sLine,columnNumber,errorObj){
        var cmpPageErrorMsg = "发生错误的信息：" + sMsg+ "、发生错误的文件：" +sUrl+ "、发生错误的行数：" + sLine+"、错误堆栈如下：" + errorObj.stack;
        var logObj = {
            "log":cmpPageErrorMsg
        }
        _cmpJsConsole("window.onerror",logObj);
    }
    var urlObj = new URL(window.location.href);
    var protocol = urlObj.protocol;
    if(protocol !== "file:"){//不是zip包本地的页面，return，不做代理处理
        return ;
    }
    var localStorageOrigin = window.localStorage;//原始的localStorage
    var ctxPath = localStorage.getItem("ctxPath");
    _cmpJsConsole("889900",ctxPath);
    var from = 'contain lsn';
    var tag = window.location.href.indexOf('lsn=1');
    if (tag == -1) {
        from = 'not contain lsn,but ctxPath is null';
        if(ctxPath && ctxPath.indexOf('null') == -1){//如果有标识说明localStorage正常，不需要再重写
            _cmpJsConsole("ctxPath-js",ctxPath);
            var isEql = _cmpJsVerify('equal',ctxPath,'ctxPath')
            if (isEql == '1'){
                _cmpJsConsole('ctxPath is not null,and equal,return');
                return
            }
            from = 'ctxPath is not null,but not equal';
        }
    }
    _cmpJsConsole("lsn_begin",from);
    const setAllData2LocalStorageOrigin = function(){
        if(canConnectNative){
            var actionParams = {
                method:"localStorage",
                action:"getAllData"
            };
            var allData = prompt.apply(window, [ JSON.stringify(actionParams) ]);
            _cmpJsConsole("allData-native",allData);
            if(allData){
                var allDataObj = JSON.parse(allData);
                for(var key in allDataObj){
                    localStorageOrigin.setItem(key,allDataObj[key])
                }
            }
        }
    };
    setAllData2LocalStorageOrigin();//将原生缓存的localstorage中的值全部再写入到原始localstorage中
    const setItem = function(key,value){
        localStorageOrigin.setItem(key,value);
        var actionParams = {
            method:"localStorage",
            action:"setItem",
            key:key,
            value:value
        }
        return prompt.apply(window, [ JSON.stringify(actionParams) ]);

    }
    const getItem = function(key){
        /*
        var value = localStorage.getItem(key);
        if(typeof value !== "undefined" && value !== null){
            _cmpJsConsole("localStorageGetItem-js",{key,value});
            return value;
        }
        */
        var value;
        if (canConnectNative) {
            var actionParams = {
                method:"localStorage",
                action:"getItem",
                key:key,
            }
            value = prompt.apply(window, [ JSON.stringify(actionParams) ]);
            _cmpJsConsole("localStorageGetItem-native",{key,value});
        }
        
        if(!value || value == null || typeof value == "undefined"){
            value = localStorageOrigin.getItem(key);
            _cmpJsConsole("localStorageGetItem-js-2",{key,value});
        }
        if(value){
            localStorageOrigin.setItem(key,value);
        }
        _cmpJsConsole("localStorageGetItem-result",{key,value});
        return value;
        /*
        var value = localStorageOrigin.getItem(key);
        if(value){
            _cmpJsConsole("getItem-js",value);
            return value;
        }
        if (canConnectNative){
            var actionParams = {
                method:"localStorage",
                action:"getItem",
                key:key,
            }
            value = prompt.apply(window, [ JSON.stringify(actionParams) ]);
            _cmpJsConsole("getItem-native",value);
            if(value){
                localStorageOrigin.setItem(key,value);
            }
        }
        return value;
        */
    }
    const removeItem = function(key){
        localStorageOrigin.removeItem(key);
        var actionParams = {
            method:"localStorage",
            action:"removeItem",
            key:key,
        }
        return prompt.apply(window, [ JSON.stringify(actionParams) ]);
    }




    const storageProxy = new Proxy(window.localStorage,{
        set:function(ls,key,newValue){
            var actionParams = {
                method:"localStorage",
                action:"setItem",
                key:key,
                value:newValue
            }
            prompt.apply(window, [ JSON.stringify(actionParams) ]);
        },
        get:function(ls,prop){

            if(typeof prop === "string" && prop === "setItem"){
                return setItem;
            }else if(prop === "getItem"){
                return getItem;
            }else if(prop === "removeItem"){
                return removeItem;
            }else if(prop === "length"){
                var length = localStorageOrigin.length;
                if(typeof length != "undefined" && length != null){
                    return length;
                }
                var actionParams = {
                    method:"localStorage",
                    action:"length"
                }
                return prompt.apply(window, [ JSON.stringify(actionParams) ]);
            }else if(prop === "clear"){
                //todo clear  不做任何处理
            }else {
                var value = localStorageOrigin.getItem(prop);
                if(value){
                    return value;
                }
                var actionParams = {
                    method:"localStorage",
                    action:"getItem",
                    key:prop,
                }
                return prompt.apply(window, [ JSON.stringify(actionParams) ]);
            }
        }
    })

    Object.defineProperty(window,"localStorage",{
        configurable:true,
        enumerable:true,
        value:storageProxy
    })
})();

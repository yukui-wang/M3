//
//  CMPJSBridge_JS.m
//  CMPLib
//
//  Created by CRMO on 2018/10/17.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import "CMPJSBridge_JS.h"

NSString *jsBridge_js(void) {
#define __cmp_js_func__(x) #x
    
    // BEGIN JS注入代码
    static NSString * preprocessorJSCode = @__cmp_js_func__(;(function() {
        'use strict';
        var SDK, Bridge;
        
        /**
         * @constructor
         * @description 桥接器构造函数
         */
        function bridge() {
            console.log('birdge');
            registGlobalFunction(this);
            this.handleMap = {};
            this.bridgeState = {};
            readyNotify(this);
        };
        
        /**
         * @description ================================ 私有函数 ================================
         */
        var acount = 0;
        /**
         * @private
         * @method readyNotify
         * @description ready事件通知
         * @param {object} _this
         */
        function readyNotify(_this) {
            if (acount === 600) {
                return console.warn('JSBridge Warn: 30s timeout warning, your page do not regist CMPBridgeReady');
            }
            if (window.CMPBridgeReady) {
                window.CMPBridgeReady(SDK);
            } else {
                acount++;
                setTimeout(function() {
                    readyNotify(_this);
                }, 50);
            }
        }
        
        /**
         * @private
         * @method registGlobalFunction
         * @description 注册事件
         * @param {object} _this bridge 实例对象
         */
        function registGlobalFunction(_this) {
            console.log('registGlobalFunction');
            /**
             * @public
             * @description 原生响应接口结果方法
             */
            window.__CMPBridgeNativeToJS__ = function(id, data) {
                //检查id
                if (!id) {
                    return console.error('JSBridge Error: bridge response, ID is not exist ');
                }
                //任务队列，释放连接池
                setTimeout(function() {
                    releaseHandle(id, _this, data);
                }, 0);
            };
            
            /**
             * @public
             * @method __CMPBridgeNativeGetParam__
             * @description iOS基于id获取参数
             * @param {string} id
             */
            window.__CMPBridgeNativeGetParam__ = function(id) {
                var header = _this.handleMap[ id ] || {};
                return JSON.stringify({
                    id: header.id,
                isSync: false,
                plugin: header.plugin,
                action: header.action,
                param: header.param
                });
            };
        }
        
        /**
         * @private
         * @method isIOS
         * @description 设备系统是否为iOS
         */
        function isIOS() {
            console.log('isIOS');
            return window.navigator.userAgent.toLocaleUpperCase().match(/IPHONE|IPAD|MAC|IPOD|ITOUCH/) ? true : false;
        }
        
        /**
         * @private
         * @method asynPostMessageToNative
         * @description JS到原生的消息异步发送器
         * @param {object} _this bridge实例指针
         * @param {string} id 接口ID
         * @param {string} plugin 类名
         * @param {string} action 原生方法名
         * @param {string} param JS给原生的参数
         */
        function asynPostMessageToNative(_this, id, plugin, action, param) {
            //iOS的处理方式
            if (isIOS()) {
                iOSAsynPostMessage(_this, id);
            } else {
                //安卓的桥接方式
                window.CMPBridge.__CMPBridgeJSToNative__(id, plugin, action, param, false);
            }
            _this.handleMap[ id ].bridgeState = 'sent';
        }
        
        /**
         * @private
         * @method syncPostMessageToNative
         * @description 同步JS -> native 发送方法
         * @param {srting} id
         * @param {object} _this
         * @param {string} plugin
         * @param {string} action
         * @param {string} param
         */
        function syncPostMessageToNative(_this, id, plugin, action, param) {
            _this.handleMap[ id ].bridgeState = 'sent';
            var result;
            //iOS
            if (isIOS()) {
                result = iOSSyncPostMessage(_this, id, plugin, action, param);
            } else {
                result = window.CMPBridge.__CMPBridgeJSToNative__(id, plugin, action, param, true);
            }
            return releaseHandle(id, _this, result);
        }
        
        /**
         * @private
         * @method iOSAsynPostMessage
         * @description iOS异步 JS -> native发消息
         * @param {object} _this
         * @param {string} id
         */
        function iOSAsynPostMessage(_this, id) {
            var iframeNode = document.createElement('iframe');
            iframeNode.id = id;
            iframeNode.src = 'jsbridge://cmp?bridgeid=' + id;
            document.body.appendChild(iframeNode);
        }
        
        /**
         * @private
         * @method iOSSyncPostMessage
         * @description iOS同步 JS -> native发消息
         * @param {object} _this
         * @param {string} id
         * @param {string} plugin
         * @param {string} action
         * @param {string} param
         */
        function iOSSyncPostMessage(_this, id, plugin, action, param) {
            var xhr = new window.XMLHttpRequest(),
            url = 'http://__jsbridge__?bridgeid=' + id;
            xhr.open('POST', url, false);
            xhr.send(JSON.stringify({
                id: id,
            plugin: plugin,
            action: action,
            isSync: true,
            param: param
            }));
            return xhr.responseText;
        }
        
        /**
         * @private
         * @method releaseHandle
         * @description 释放handle map
         * @param {String} id handle id
         * @param {Object} _this 桥接器指针
         * @param {String} data 原生返回的数据
         */
        function releaseHandle(id, _this, response) {
            var header = _this.handleMap[ id ] || {};
            _this.handleMap[ id ].bridgeState = 'finish';
            try {
                response = JSON.parse(response);
            } catch(e) {
                delete _this.handleMap[ id ];
                return console.error('JSBridge Error: response data JSON parse fail, plugin :' + header.plugin + ', action:' + header.action);
            }
            if (response.code !== '200') {
                console.error('JSBridge Error: plugin :' + header.plugin + ', action:' + header.action + ' error');
                header.fail && header.fail();
            } else {
                header.success && header.success(response.data);
            }
            delete _this.handleMap[ id ];
            var node = document.getElementById(id);
            node && node.remove();
            return response.data;
        }
        
        //原型链
        bridge.prototype = {
            
            /**
             * @public
             * @method exec
             * @description 命令执行函数
             * @param {String} plugin 原生类名
             * @param {String} action 原生的方法
             * @param {Function} success 成功回调函数
             * @param {Function} fail 失败回调函数
             */
        exec: function(plugin, action, param, success, fail) {
            var _this = this,
            id = UUID.generate();
            try {
                param = JSON.stringify(param);
            } catch(e) {
                //异常处理
                msg = 'JSBridge Error:Exec plugin-' + plugin + ' action-' + action + ' translate JSON string fail';
                console.error(msg);
                return;
            }
            this.handleMap[ id ] = {
                id: id,
            plugin: plugin,
            param: param,
            action: action,
            success: success,
            fail: fail,
            isSync: false,
            bridgeState: 'created'
            };
            asynPostMessageToNative(_this, id, plugin, action, param);
        },
            
            /**
             * @public
             * @method syncExec
             * @description 同步执行原生接口函数
             * @param {string} plugin 原生类名
             * @param {string} action 原生方法名
             * @param {any} param 传递给原生的参数
             */
        syncExec: function(plugin, action, param) {
            var _param = param,
            id = window.UUID.generate();
            //安卓使用字符串
            try {
                _param = JSON.stringify(_param);
            } catch(e) {
                //异常处理
                var msg = 'JSBridge Error:syncExec plugin-' + plugin + ' action-' + action + ' translate JSON srting fail';
                console.error(msg);
                return;
            }
            this.handleMap[ id ] = {
                id: id,
            plugin: plugin,
            action: action,
            param: _param,
            isSync: true,
            bridgeState: 'created'
            };
            return syncPostMessageToNative(this, id, plugin, action, _param);
        }
        };
        
        /**
         * @constructor
         * @description sdk API
         */
        function sdk() {
            console.log('sdk');
        }
        
        sdk.prototype = {
        demoAsyc: function(userName, success, fail) {
            Bridge.exec('CMPAppManagerPlugin', 'getAppList', {key: userName}, success, fail);
        },
            
        demoSync: function(aaa) {
            Bridge.syncExec('plugin', 'action', {aaa: aaa});
        }
        };
        window.sdk = SDK = new sdk();
        window.__cmpBridge__ = Bridge = new bridge();
    })();
                                                            
    /**
     * @class
     * @classdesc {@link UUID} object.
     * @hideconstructor
     */
                                                            
                                                            (function () {
        'use strict';
        
        // Core Component {{{
        
        /**
         * Generates a version 4 UUID as a hexadecimal string.
         * @returns {string} Hexadecimal UUID string.
         */
        UUID.generate = function () {
            var rand = UUID._getRandomInt, hex = UUID._hexAligner;
            return hex(rand(32), 8)          // time_low
            + '-'
            + hex(rand(16), 4)          // time_mid
            + '-'
            + hex(0x4000 | rand(12), 4) // time_hi_and_version
            + '-'
            + hex(0x8000 | rand(14), 4) // clock_seq_hi_and_reserved clock_seq_low
            + '-'
            + hex(rand(48), 12);        // node
        };
        
        /**
         * Returns an unsigned x-bit random integer.
         * @private
         * @param {number} x Unsigned integer ranging from 0 to 53, inclusive.
         * @returns {number} Unsigned x-bit random integer (0 <= f(x) < 2^x).
         */
        UUID._getRandomInt = function (x) {
            if (x < 0 || x > 53) { return NaN; }
            var n = 0 | Math.random() * 0x40000000; // 1 << 30
            return x > 30 ? n + (0 | Math.random() * (1 << x - 30)) * 0x40000000 : n >>> 30 - x;
        };
        
        /**
         * Converts an integer to a zero-filled hexadecimal string.
         * @private
         * @param {number} num
         * @param {number} length
         * @returns {string}
         */
        UUID._hexAligner = function (num, length) {
            var str = num.toString(16), i = length - str.length, z = '0';
            for (; i > 0; i >>>= 1, z += z) { if (i & 1) { str = z + str; } }
            return str;
        };
        // }}}
        
        // create local namespace
        function UUID() { }
        // for nodejs
        if (typeof module === 'object' && typeof module.exports === 'object') {
            module.exports = UUID;
        } else if (window.define && define.cmd) {
            define('cmpUtil/cmp-uuid.js', function (require, exports, module) {
                module.exports = UUID;
            });
        }
        window.UUID = UUID;
    })();
    ); // END JS注入代码
    
#undef __cmp_js_func__
    return preprocessorJSCode;
}

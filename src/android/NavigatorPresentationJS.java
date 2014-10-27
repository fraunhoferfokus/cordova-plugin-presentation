/*
 * Copyright 2014 Fraunhofer FOKUS
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * AUTHORS: Louay Bassbouss <louay.bassbouss@fokus.fraunhofer.de>
 *          Martin Lasak <martin.lasak@fokus.fraunhofer.de>
 */
package de.fhg.fokus.famium.presentation;

/**
 * 
 * This class collects all JavaScript Code that will be injected in WebViews. At the moment there is only one constant  <code>RECEIVER</code>. New contants my be added in future releases.
 *
 */
public class NavigatorPresentationJS {
	/**
	 * RECEIVER contains a minified version of the JavaScript file receiver.js. It will be injected in the WebView of the presenting page after page load finished.
	 */
	public static String RECEIVER = "javascript:(function(d){var f=function(a){var b=null,e=null;a.onstatechange=function(){'function'==typeof e&&e.call(null)};a.onmessage=function(a){'function'==typeof b&&b.call(null,a)};Object.defineProperty(this,'state',{get:function(){return a&&a.state||null}});Object.defineProperty(this,'onmessage',{get:function(){return b},set:function(a){if('function'==typeof a||null==a)b=a}});Object.defineProperty(this,'onstatechange',{get:function(){return e},set:function(a){if('function'==typeof a||null==a)e=a}});Object.defineProperty(this, 'postMessage',{get:function(){return function(b){return a.postMessage(b)}}});Object.defineProperty(this,'close',{get:function(){return function(){return a.close()}}})},g=function(a,b){this.type=a;var e=b&&(b.session||null);Object.defineProperty(this,'session',{get:function(){return e}})},c=new function(){var a=null;Object.defineProperty(this,'onpresent',{get:function(){return a},set:function(b){if('function'==typeof b||'undefined'==typeof b||null==b)a=b,d.onpresent=a?function(b){b=new f(b);b=new g('PresentEvent', {session:b});a.call(null,b)}:null}})};Object.defineProperty(window.navigator,'presentation',{get:function(){return c}})})(function(d){var f={};d.onsession=function(c){console.log('onsession '+c.id);f[c.id]=f[c.id]||c;var a=null,b=null;Object.defineProperty(c,'onmessage',{get:function(){return a},set:function(b){if('function'==typeof b||'undefined'==typeof b||null==b)a=b}});Object.defineProperty(c,'onstatechange',{get:function(){return b},set:function(a){if('function'==typeof a||'undefined'==typeof a|| null==a)b=a}});Object.defineProperty(c,'postMessage',{get:function(){return function(a){return d.postMessage(c.id,a)}}});Object.defineProperty(c,'close',{get:function(){return function(){return d.close(c.id)}}});g.onpresent&&g.onpresent(c)};d.onmessage=function(c,a){console.log('onmessage '+a);var b=f[c];b&&b.onmessage&&b.onmessage.call(null,a)};d.onstatechange=function(c,a){console.log('onstatechange '+a);var b=f[c];b&&(b.state=a,b.onstatechange&&b.onstatechange.call(null))};var g=new function(){var c= null;Object.defineProperty(this,'onpresent',{get:function(){return c},set:function(a){('function'==typeof a||'undefined'==typeof a||null==a)&&(c=a)&&d.setOnPresent()}})};return g}(NavigatorPresentationJavascriptInterface));";
}

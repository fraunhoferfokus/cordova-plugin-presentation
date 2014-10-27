/*
 * Copyright 2014 Fraunhofer FOKUS
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * AUTHORS: Martin Lasak <martin.lasak@fokus.fraunhofer.de>
 */

#ifndef EventTarget_h
#define EventTarget_h

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class Event;

/*

 interface EventTarget {
 void addEventListener(DOMString type, EventListener? callback, optional boolean capture = false);
 void removeEventListener(DOMString type, EventListener? callback, optional boolean capture = false);
 boolean dispatchEvent(Event event);
 };

 callback interface EventListener {
 void handleEvent(Event event);
 };

 */

@interface EventTarget : NSObject

- (void)addEventListener: (NSString *)type : (JSValue *)callback : (bool) capture;
- (void)removeEventListener: (NSString *)type : (JSValue *)callback : (bool) capture;
- (void)dispatchEvent: (Event *) event;

@end

#endif

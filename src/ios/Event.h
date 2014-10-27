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

#ifndef Event_h
#define Event_h

#import <Foundation/Foundation.h>
#import "EventTarget.h"

@interface Event : NSObject

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) EventTarget *target;
@property (nonatomic, readonly) EventTarget *currentTarget;

FOUNDATION_EXPORT NSNumber *const NONE;
FOUNDATION_EXPORT NSNumber *const CAPTURING_PHASE;
FOUNDATION_EXPORT NSNumber *const AT_TARGET;
FOUNDATION_EXPORT NSNumber *const BUBBLING_PHASE;

@property (readonly) NSNumber *eventPhase;
@property (readonly) Boolean bubbles;
@property (readonly) Boolean cancelable;
@property (readonly) Boolean defaultPrevented;
@property (readonly) NSDate *timeStamp;

- (void)stopPropagation;
- (void)stopImmediatePropagation;
- (void)preventDefault;
- (Event *)initEvent: (NSString *)type :(Boolean)bubbles :(Boolean)cancelable;
- (void)setEventTargets: (EventTarget *)target :(EventTarget *)currentTarget;

@end

#endif


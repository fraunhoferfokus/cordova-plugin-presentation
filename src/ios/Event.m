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

#import "Event.h"

@implementation Event

- (void)stopPropagation
{

}

- (void)stopImmediatePropagation
{

}

- (void)preventDefault
{

}

- (Event *)initEvent: (NSString *)type :(Boolean)bubbles :(Boolean)cancelable
{
    _type = type;
    _cancelable = cancelable;
    _bubbles = bubbles;

    _timeStamp = [[NSDate alloc] init];

    return self;
}

- (void)setEventTargets: (EventTarget *)target :(EventTarget *)currentTarget
{
    _target = target;
    _currentTarget = currentTarget;
}

@end

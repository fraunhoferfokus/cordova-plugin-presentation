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

#import "EventTarget.h"

@implementation EventTarget

- (void)addEventListener: (NSString *)type : (JSValue *)callback : (bool) capture
{
    NSLog(@"Added EventListener!");
    if(capture){
      NSLog(@"capture true!");
    } else {
        NSLog(@"capture false!");
    }
    [callback callWithArguments:@[type]];
}

- (void)removeEventListener: (NSString *)type : (JSValue *)callback : (bool) capture
{
    NSLog(@"Removed EventListener!");
}

- (void)dispatchEvent: (Event *) event
{

}

@end

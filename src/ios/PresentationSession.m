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

#import <Foundation/Foundation.h>
#import "PresentationSession.h"

@implementation PresentationSession

- (id)init
{
    return [super init];
}

- (id)initWithSid
{
    self = [super init];
    self.sid = [[NSUUID UUID] UUIDString];
    _state = @"disconnected";
    return self;
}

- (id)initWithSid:(NSString*)sid
{
    self = [super init];
    self.sid = sid;
    _state = @"disconnected";
    return self;
}

- (void)setState:(NSString*)state
{
     NSLog(@"PresentationSession setState");
    if(![_state isEqual:state]){
        _state = state;
        [self.delegate stateChanged:self.sid];
    }
}

- (void)postMessage :(NSString *) message
{
    NSLog(@"PresentationSession close");
    [self.delegate msgPosted:self.sid withMsg:message];
}

- (void)close
{
    NSLog(@"PresentationSession close");
    [self.delegate closeRequested: self.sid];
}

@end

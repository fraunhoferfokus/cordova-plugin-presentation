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

#import "NavigatorPresentation.h"
#import "JointContext.h"
#import "PresentEvent.h"

@interface NavigatorPresentation () < JS_NavigatorPresentation>

@end

@implementation NavigatorPresentation

-(NavigatorPresentation *)initWithSession:(PresentationSession *)session
{
    self = [super init];
    self.session = session;
    //[self addObserver:self forKeyPath:@"onpresent"];
    [self addObserver:self forKeyPath:@"onpresent" options:NSKeyValueObservingOptionNew context:NULL];
    return self;
}

-(void)dealloc {
    [self removeObserver:self forKeyPath:@"onpresent"];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"onpresent"]) {
        [self invokeOnPresent];
    }
}

- (void)invokeOnPresent
{
    PresentEvent *event = [[PresentEvent alloc] initEvent:@"present" :false :false];
    event.session = self.session;

    // Call on Webscreen in JavaScript context and push the session
    if([self.onpresent isObject]){
        [self.onpresent callWithArguments:@[event]];
        // Now, since session is on both sides, switch to "connected"
        [self.session setState:@"connected"];

    } else {
        NSLog(@"no function callback set   ! ");
        _onpresent = nil;
    }
}


@end



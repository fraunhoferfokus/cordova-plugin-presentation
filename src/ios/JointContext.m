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

#import "JointContext.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>

static const char kJCJavaScriptContext[] = "jc_javaScriptContext";

static NSHashTable* g_webViews = nil;

@interface UIWebView (JC_JavaScriptCore_private)
- (void) jc_didCreateJavaScriptContext:(JSContext *)jc_javaScriptContext;
@end

@protocol JCWebFrame <NSObject>
- (id) parentFrame;
@end

@implementation NSObject (JC_JavaScriptContext)

- (void) webView: (id) unused didCreateJavaScriptContext: (JSContext*) ctx forFrame: (id<JCWebFrame>) frame
{
    NSParameterAssert( [frame respondsToSelector: @selector( parentFrame )] );

    // only interested in root-level frames
    if ( [frame respondsToSelector: @selector( parentFrame) ] && [frame parentFrame] != nil )
        return;

    void (^notifyDidCreateJavaScriptContext)() = ^{

        for ( UIWebView* webView in g_webViews )
        {
            NSString* cookie = [NSString stringWithFormat: @"jc_jscWebView_%lud", (unsigned long)webView.hash ];

            [webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"var %@ = '%@'", cookie, cookie ] ];

            if ( [ctx[cookie].toString isEqualToString: cookie] )
            {
                [webView jc_didCreateJavaScriptContext: ctx];
                return;
            }
        }
    };

    if ( [NSThread isMainThread] )
    {
        notifyDidCreateJavaScriptContext();
    }
    else
    {
        dispatch_async( dispatch_get_main_queue(), notifyDidCreateJavaScriptContext );
    }
}

@end


@implementation UIWebView (JC_JavaScriptContext)

+ (id) allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        g_webViews = [NSHashTable weakObjectsHashTable];
    });

    NSAssert( [NSThread isMainThread], @"uh oh - why aren't we on the main thread?");

    id webView = [super allocWithZone: zone];

    [g_webViews addObject: webView];

    return webView;
}

- (void) jc_didCreateJavaScriptContext:(JSContext *)jc_javaScriptContext
{
    [self willChangeValueForKey: @"jc_javaScriptContext"];

    objc_setAssociatedObject( self, kJCJavaScriptContext, jc_javaScriptContext, OBJC_ASSOCIATION_RETAIN);

    [self didChangeValueForKey: @"jc_javaScriptContext"];

    if ( [self.delegate respondsToSelector: @selector(webView:didCreateJavaScriptContext:)] )
    {
        id<JCWebViewDelegate> delegate = ( id<JCWebViewDelegate>)self.delegate;
        [delegate webView: self didCreateJavaScriptContext: jc_javaScriptContext];
    }
}

- (JSContext*) jc_javaScriptContext
{
    JSContext* javaScriptContext = objc_getAssociatedObject( self, kJCJavaScriptContext );

    return javaScriptContext;
}

@end

//
//  UIView+FKGuard.m
//  FKGuardView
//
//  Created by andwell on 17/2/20.
//  Copyright © 2017年 andwell. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "UIView+FKGuard.h"
#import <objc/runtime.h>

@implementation UIView (FKGuard)

+ (void)swizzleInstanceMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector {
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL addMethod=class_addMethod(class,
                                   originalSelector,
                                   method_getImplementation(swizzledMethod),
                                   method_getTypeEncoding(swizzledMethod));
    if (addMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }else {
        class_replaceMethod(class,
                            swizzledSelector,
                            class_replaceMethod(class,
                                                originalSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}

static NSDictionary *methods;

+ (void)initialize {
    if (self != UIView.self) return;
    
    if (!methods) {
        methods = @{@"setNeedsLayout": @"fk_setNeedsLayout",
                    @"setNeedsDisplay": @"fk_setNeedsDisplay",
                    @"setNeedsDisplayInRect:": @"fk_setNeedsDisplayInRect:",
                    @"addSubview:": @"fk_addSubview:"};
    }
    
    [methods enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [self swizzleInstanceMethod:NSSelectorFromString(key) withMethod:NSSelectorFromString(value)];
    }];
}

- (void)fk_setNeedsLayout {
    if (![NSThread isMainThread]) {
        [self assertWithInfo:@"UIKit can't operating on the non-mainThread !"];
    }else {
        [self fk_setNeedsLayout];
    }
}

- (void)fk_setNeedsDisplay {
    if (![NSThread isMainThread]) {
        [self assertWithInfo:@"UIKit can't operating on the non-mainThread !"];
    }else {
        [self fk_setNeedsDisplay];
    }
}

- (void)fk_setNeedsDisplayInRect:(CGRect)rect {
    if (![NSThread isMainThread]) {
        [self assertWithInfo:@"UIKit can't operating on the non-mainThread !"];
    }else {
        [self fk_setNeedsDisplayInRect:rect];
    }
}

- (void)fk_addSubview:(UIView *)view {
    if (view == self) {
        [self assertWithInfo:@"Can't add self as subview !"];
    }else {
        [self fk_addSubview:view];
    }
}

- (void)assertWithInfo:(NSString *)errorInfo {
    #if DEBUG
    NSAssert(0, errorInfo, [NSThread callStackSymbols]);
    #else
        // You can do some logs to help know of the error.
    #endif
}

@end


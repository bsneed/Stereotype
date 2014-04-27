//
//  RFBlurWindow.m
//  Stereotype
//
//  Created by Brandon Sneed on 2/8/14.
//  Copyright (c) 2014 redf.net. All rights reserved.
//

#import "RFBlurWindow.h"
#import "CGSInternal.h"

typedef CGError CGSSetWindowBackgroundBlurRadiusFunction(CGSConnectionID cid, CGSWindowID wid, NSUInteger blur);
CGSSetWindowBackgroundBlurRadiusFunction* GetCGSSetWindowBackgroundBlurRadiusFunction(void);

static void *GetFunctionByName(NSString *library, char *func)
{
    CFBundleRef bundle;
    CFURLRef bundleURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef) library, kCFURLPOSIXPathStyle, true);
    CFStringRef functionName = CFStringCreateWithCString(kCFAllocatorDefault, func, kCFStringEncodingASCII);
    bundle = CFBundleCreate(kCFAllocatorDefault, bundleURL);
    void *f = NULL;
    if (bundle)
    {
        f = CFBundleGetFunctionPointerForName(bundle, functionName);
        CFRelease(bundle);
    }
    CFRelease(functionName);
    CFRelease(bundleURL);
    return f;
}

@implementation RFBlurWindow
{
    int blurFilter;
    double blurRadius_;
}

CGSSetWindowBackgroundBlurRadiusFunction* GetCGSSetWindowBackgroundBlurRadiusFunction(void)
{
    static BOOL tried = NO;
    static CGSSetWindowBackgroundBlurRadiusFunction *function = NULL;
    if (!tried) {
        function  = GetFunctionByName(@"/System/Library/Frameworks/ApplicationServices.framework",
                                      "CGSSetWindowBackgroundBlurRadius");
        tried = YES;
    }
    return function;
}

- (void)enableBlur:(double)radius
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
    const double kEpsilon = 0.001;
    if (blurFilter && fabs(blurRadius_ - radius) < kEpsilon)
        return;
    
    CGSConnectionID con = CGSMainConnectionID();
    if (!con)
        return;

    CGSSetWindowBackgroundBlurRadiusFunction* function = GetCGSSetWindowBackgroundBlurRadiusFunction();
    if (function)
        function(con, (CGSWindowID)[self windowNumber], (int)radius);
    else
        NSLog(@"Couldn't get blur function");

    blurRadius_ = radius;
#endif
}

- (void)disableBlur
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
    CGSConnectionID con = CGSMainConnectionID();
    if (!con)
        return;
    
    CGSSetWindowBackgroundBlurRadiusFunction* function = GetCGSSetWindowBackgroundBlurRadiusFunction();
    if (function)
        function(con, (CGSWindowID)[self windowNumber], 0);
    else
    if (blurFilter)
    {
        CGSRemoveWindowFilter(con, (CGSWindowID)[self windowNumber], blurFilter);
        CGSReleaseCIFilter(CGSMainConnectionID(), blurFilter);
        blurFilter = 0;
    }
#endif
}

@end

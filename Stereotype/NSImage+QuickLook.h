//
//  NSImage+QuickLook.h
//  QuickLookTest
//
//  Created by Matt Gemmell on 29/10/2007.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (QuickLook)

- (NSRect) centerRect: (NSRect) smallRect inRect: (NSRect) bigRect;

//+ (NSImage *)imageWithPreviewOfFileAtPath:(NSURL *)fileURL ofSize:(NSSize)size asIcon:(BOOL)icon;
//+ (NSImage *)albumArtForFileURL:(NSURL *)fileURL;
+ (NSImage *)imageFromAlbum:(NSString *)album artist:(NSString *)artist url:(NSURL *)url;

- (CGImageRef)CGImage;

@end


enum {
    GTMScaleProportionally = 0,   // Fit proportionally
    GTMScaleToFit,                // Forced fit (distort if necessary)
    GTMScaleNone                  // Don't scale (clip)
};
typedef NSUInteger GTMScaling;

CGRect GTMCGRectScale(CGRect inRect, CGFloat xScale, CGFloat yScale);
CGRect GTMCGScaleRectangleToSize(CGRect scalee, CGSize size, GTMScaling scaling);


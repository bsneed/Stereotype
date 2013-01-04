//
//  NSImage+QuickLook.h
//  QuickLookTest
//
//  Created by Matt Gemmell on 29/10/2007.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (QuickLook)


+ (NSImage *)imageWithPreviewOfFileAtPath:(NSURL *)fileURL ofSize:(NSSize)size asIcon:(BOOL)icon;
//+ (NSImage *)albumArtForFileURL:(NSURL *)fileURL;
+ (NSImage *)imageFromAlbum:(NSString *)album artist:(NSString *)artist url:(NSURL *)url;

- (CGImageRef)CGImage;

@end

//
//  NSImage+QuickLook.m
//  QuickLookTest
//
//  Created by Matt Gemmell on 29/10/2007.
//

#import "NSImage+QuickLook.h"
#import <QuickLook/QuickLook.h> // Remember to import the QuickLook framework into your project!
#import "RFMetadata.h"
#import "NSFileManager+RFExtensions.h"

@implementation NSImage (QuickLook)

static BOOL useImageCache = YES;

+ (NSImage *)imageWithPreviewOfFileAtPath:(NSURL *)fileURL ofSize:(NSSize)size asIcon:(BOOL)icon
{
	if (!fileURL)
		return nil;
	
	NSImage *result = nil;
	
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:icon] 
                                                     forKey:(NSString *)kQLThumbnailOptionIconModeKey];
    CGImageRef ref = QLThumbnailImageCreate(kCFAllocatorDefault, 
                                            (__bridge CFURLRef)fileURL, 
                                            CGSizeMake(size.width, size.height),
                                            (__bridge CFDictionaryRef)dict);
    
    if (ref != NULL) {
        // Take advantage of NSBitmapImageRep's -initWithCGImage: initializer, new in Leopard,
        // which is a lot more efficient than copying pixel data into a brand new NSImage.
        // Thanks to Troy Stephens @ Apple for pointing this new method out to me.
        NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:ref];
        NSImage *newImage = nil;
        if (bitmapImageRep) {
            newImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
            [newImage addRepresentation:bitmapImageRep];
            
            if (newImage) {
                result = newImage;
            }
        }
    }
	if (ref)
		CFRelease(ref);
    
    return result;
}

- (CGImageRef)CGImage
{
    NSRect rect = NSMakeRect(0, 0, self.size.width, self.size.height);
    return [self CGImageForProposedRect:&rect context:nil hints:nil];
}


+ (void)saveImageToCache:(NSImage *)image
{
    NSData *data = [image TIFFRepresentation];
    if (data)
    {
        NSURL *supportDir = [[[NSFileManager defaultManager] applicationMusicDirectory] URLByAppendingPathComponent:@"ArtCache"];
        useImageCache = [[NSFileManager defaultManager] findOrCreateDirectory:supportDir];
        if (useImageCache)
        {
            NSURL *url = [supportDir URLByAppendingPathComponent:image.name];
            [data writeToFile:[url path] atomically:NO];
        }
    }
}

+ (NSImage *)getImageFromCache:(NSURL *)fileURL
{
    NSURL *supportDir = [[NSFileManager defaultManager] applicationSupportDirectory];
    NSString *fileName = [NSString stringWithFormat:@"%lu.tiff", [[fileURL lastPathComponent] hash]];
    NSURL *url = [supportDir URLByAppendingPathComponent:fileName];

    NSImage *image = [NSImage imageNamed:fileName];
    if (!image)
        image = [[NSImage alloc] initWithContentsOfURL:url];
    
    return image;
}


+ (NSImage *)albumArtForFileURL:(NSURL *)fileURL
{
    //Get album cover from folder.jpg if not already loaded from file metadata
    NSError *err = nil;
    NSImage *albumArt = nil;
    
    RFMetadata *metadata = [[RFMetadata alloc] initWithURL:fileURL];
    if (metadata)
    {
        albumArt = [metadata getAlbumArt];
    }
    
    if (!albumArt)
    {
        NSURL *fileFolder = [fileURL URLByDeletingLastPathComponent];
        
        NSURL *folderImage = [fileFolder URLByAppendingPathComponent:@"folder.jpg"];
        
        if ([folderImage checkResourceIsReachableAndReturnError:&err]) {
            albumArt = [[NSImage alloc] initWithContentsOfURL:folderImage];
        } else {
            folderImage = [fileFolder URLByAppendingPathComponent:@"cover.jpg"];
            if ([folderImage checkResourceIsReachableAndReturnError:&err]) {
                albumArt = [[NSImage alloc] initWithContentsOfURL:folderImage];
            }
            else {
                NSFileManager *fileMgr = [[NSFileManager alloc] init];
                NSArray *folderContents = [fileMgr contentsOfDirectoryAtPath:[fileFolder path] error:NULL];
                NSArray *sleevePngs = [folderContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH 'Sleeve.png'"]];
                
                if ([sleevePngs count]>0) {
                    albumArt = [[NSImage alloc] initWithContentsOfURL:[fileFolder URLByAppendingPathComponent:[sleevePngs objectAtIndex:0]]];
                }
                else {
                    NSArray *sleeveOtherJpgs = [folderContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"]];
                    if ([sleeveOtherJpgs count]>0) {
                        albumArt = [[NSImage alloc] initWithContentsOfURL:[fileFolder URLByAppendingPathComponent:[sleeveOtherJpgs objectAtIndex:0]]];
                    }
                }
            }
            
        }
    }
    
    if (albumArt)
    {
        return albumArt;
    }
    else
    {
        albumArt = [NSImage imageWithPreviewOfFileAtPath:fileURL ofSize:NSMakeSize(201, 201) asIcon:NO];
        // fall back
        if (albumArt)
            return albumArt;
        else
            return [NSImage imageNamed:@"albumArt"];
    }
    
    return albumArt;
}

+ (NSImage *)imageFromAlbum:(NSString *)album artist:(NSString *)artist url:(NSURL *)url
{
    if (useImageCache)
    {
        NSString *name = [NSString stringWithFormat:@"%lu.tiff", [[url lastPathComponent] hash]];
        NSImage *result = [NSImage imageNamed:name];
    
        if (!result)
        {
            result = [NSImage getImageFromCache:url];
        }
        
        if (!result)
        {
            result = [NSImage albumArtForFileURL:url];
            if (result)
            {
                [result setName:name];
                //[result setCacheMode:NSImageCacheAlways];
                [NSImage saveImageToCache:result];
            }
        }
        
        return result;
    }

    return [NSImage albumArtForFileURL:url];
}


@end

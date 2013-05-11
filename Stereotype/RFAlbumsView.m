//
//  RFArtistsView.m
//  Stereotype
//
//  Created by brandon on 12/23/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFAlbumsView.h"
#import "RFCoverViewCell.h"
#import "RFSongsView.h"
#import "RFLibraryViewController.h"

@implementation RFAlbumsView
{
    NSUInteger selectedTrackIndex;
    NSImage *blankArtImage;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.title = @"Albums";
    self.collectionView.cellSize = NSMakeSize(203, 212);
    self.collectionView.allowsDragging = YES;
    self.collectionView.allowsMultipleSelection = YES;
    blankArtImage = [NSImage imageNamed:@"albumArt"];

    [self loadAlbums];
    [self setupNotificationListening];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (void)setupNotificationListening
{
    __weak RFAlbumsView *weakSelf = self;
    
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:kLibraryUpdatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf loadAlbums];
    }];
}

- (void)loadAlbums
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"compilation" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"albumArtist" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"albumTitle" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[sortDescriptor1, sortDescriptor2, sortDescriptor3];
    
    __block NSString *albumTitle = nil;
    __block NSString *albumArtist = nil;
    NSMutableArray *albumTracks = [[NSMutableArray alloc] init];
    NSArray *tracks = [database allObjectsForEntity:@"RFTrackEntity" sortDescriptors:sortDescriptors filteredBy:nil];
    
    [tracks enumerateObjectsUsingBlock:^(RFTrackEntity *obj, NSUInteger idx, BOOL *stop) {
        if (![obj.albumTitle isEqualToString:albumTitle] || ![obj.albumArtist isEqualToString:albumArtist])
            if ((obj.albumTitle != nil && obj.albumTitle.length > 0))
                [albumTracks addObject:obj];
        albumTitle = obj.albumTitle;
        albumArtist = obj.albumArtist;
    }];
    
    NSArray *items = albumTracks;
    if (self.searchString && self.searchString.length > 0)
    {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"albumTitle contains[cd] %@ OR albumArtist contains[cd] %@", self.searchString, self.searchString];
        items = [items filteredArrayUsingPredicate:filterPredicate];
    }
    
    NSArray *filteredItems = [items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"albumArtist != nil"]];
    
    self.items = filteredItems;
    [self.collectionView reloadData];
}

- (void)setSearchString:(NSString *)searchString
{
    if ([_searchString isEqualToString:searchString])
        return;
    
    _searchString = searchString;
    
    [self loadAlbums];
}

#pragma mark - CollectionView delegate/datasource

- (NSUInteger)numberOfCellsInCollectionView:(JUCollectionView *)collectionView
{
    return self.items.count;
}

- (JUCollectionViewCell *)collectionView:(JUCollectionView *)collectionView cellForIndex:(NSUInteger)index;
{
    static NSString *cellIdentifier = @"coverViewCell";
    RFCoverViewCell *cell = (RFCoverViewCell *)[collectionView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[RFCoverViewCell alloc] initWithReuseIdentifier:cellIdentifier];
    
    RFTrackEntity *track = (RFTrackEntity *)[self.items objectAtIndex:index];
    
    cell.image = nil;
    cell.albumTitle = @"Unknown Album";
    cell.artistName = @"Unknown Artist";
    cell.playlistName = @"";
    cell.selected = NO;
    
    if (track.albumTitle && track.albumTitle.length > 0)
        cell.albumTitle = track.albumTitle;
    
    if (track.compilation.boolValue)
        cell.artistName = @"Various Artists";
    else
    if (track.albumArtist && track.albumArtist.length > 0)
        cell.artistName = track.albumArtist;
    else
    if (track.artist && track.artist.length > 0)
        cell.artistName = track.artist;
    
    NSString *url = track.url;
    if (url && [url length] > 0)
    {
        cell.url = url;
        __weak typeof(cell) weakCell = cell;
        [_imageQueue addOperationWithBlock:^{
            NSImage *image = [NSImage imageFromAlbum:track.albumTitle artist:track.artist url:[NSURL URLWithString:url]];
            if ([weakCell.url isEqualToString:track.url])
            {
                weakCell.image = (NSImage *)image;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [weakCell setNeedsDisplay:YES];
                }];
            }
        }];
    }
    
    return cell;
}

- (void)collectionView:(JUCollectionView *)collectionView didDoubleClickedCellAtIndex:(NSUInteger)index
{
    RFTrackEntity *selectedItem = (RFTrackEntity *)[self.items objectAtIndex:index];
    
    RFSongsView *songsView = [RFSongsView loadFromNib];
    songsView.title = selectedItem.albumTitle;
    [self.navigationController pushView:songsView];
    songsView.album = selectedItem.albumTitle;
    songsView.viewStyle = RFSongsViewStyleAlbum;
}


/*- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView cellForObject:(id)object
{
    RFCoverViewCell *cell = [[RFCoverViewCell alloc] init];
    
    cell.imageView.image = blankArtImage;
    
    RFTrackEntity *track = (RFTrackEntity *)object;
    
    cell.albumTitle = @"Unknown Album";
    cell.artistName = @"Unknown Artist";
    cell.playlistName = @"";
    
    if (track.albumTitle && track.albumTitle.length > 0)
        cell.albumTitle = track.albumTitle;
    
    if (track.compilation.boolValue)
        cell.artistName = @"Various Artists";
    else
    if (track.albumArtist && track.albumArtist.length > 0)
        cell.artistName = track.albumArtist;
    else
    if (track.artist && track.artist.length > 0)
        cell.artistName = track.artist;
    
    NSString *url = track.url;
    if (url && [url length] > 0)
    {
        [_imageQueue addOperationWithBlock:^{
            NSImage *image = [NSImage imageFromAlbum:track.albumTitle artist:track.artist url:[NSURL URLWithString:url]];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                cell.image = (NSImage *)image;
                [cell.view setNeedsDisplay:YES];
            }];
        }];
    }
    
    return cell;
}

- (void)collectionView:(RFCollectionView *)collectionView doubleClickOnObject:(id)object
{
    RFTrackEntity *selectedItem = (RFTrackEntity *)object;
    
    RFSongsView *songsView = [RFSongsView loadFromNib];
    songsView.title = selectedItem.albumTitle;
    [self.navigationController pushView:songsView];
    songsView.album = selectedItem.albumTitle;
    songsView.viewStyle = RFSongsViewStyleAlbum;    
}

- (void)collectionView:(RFCollectionView *)collectionView collectionItem:(RFCoverViewCell *)item drawRectForObject:(id)object dirtyRect:(NSRect)dirtyRect
{
    //// General Declarations
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    //// Color Declarations
    NSColor* startColor = [NSColor colorWithCalibratedRed: 0.644 green: 0 blue: 0.367 alpha: 1];
    NSColor* endColor = [NSColor colorWithCalibratedRed: 0.306 green: 0.07 blue: 0.203 alpha: 1];
    NSColor* topHighlightColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0.399];
    NSColor* bottomShadowColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 0.3];
    NSColor* nameTextColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
    NSColor* subtitleColor = [NSColor colorWithCalibratedRed: 0.653 green: 0.648 blue: 0.648 alpha: 1];
    
    //// Gradient Declarations
    NSGradient* gradient = [[NSGradient alloc] initWithStartingColor: startColor endingColor: endColor];
    
    //// Shadow Declarations
    NSShadow* highlightShadow = [[NSShadow alloc] init];
    [highlightShadow setShadowColor: topHighlightColor];
    [highlightShadow setShadowOffset: NSMakeSize(0.1, -1.1)];
    [highlightShadow setShadowBlurRadius: 0];
    NSShadow* backgroundShadow = [[NSShadow alloc] init];
    [backgroundShadow setShadowColor: bottomShadowColor];
    [backgroundShadow setShadowOffset: NSMakeSize(0.1, -2.1)];
    [backgroundShadow setShadowBlurRadius: 8.5];
    NSShadow* textShadow = [[NSShadow alloc] init];
    [textShadow setShadowColor: bottomShadowColor];
    [textShadow setShadowOffset: NSMakeSize(0.1, -1.0)];
    [textShadow setShadowBlurRadius: 1.0];
    
    //// Abstracted Attributes
    NSString* nameTextContent = item.albumTitle;
    NSString* subtitleTextContent = item.artistName;
    
    if (item.selected)
    {
        //// selectionRectangle Drawing
        NSBezierPath* selectionRectanglePath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(28, 45, 146, 146) xRadius: 9 yRadius: 9];
        [NSGraphicsContext saveGraphicsState];
        [backgroundShadow set];
        CGContextBeginTransparencyLayer(context, NULL);
        [gradient drawInBezierPath: selectionRectanglePath angle: -90];
        CGContextEndTransparencyLayer(context);
        
        ////// selectionRectangle Inner Shadow
        NSRect selectionRectangleBorderRect = NSInsetRect([selectionRectanglePath bounds], -highlightShadow.shadowBlurRadius, -highlightShadow.shadowBlurRadius);
        selectionRectangleBorderRect = NSOffsetRect(selectionRectangleBorderRect, -highlightShadow.shadowOffset.width, -highlightShadow.shadowOffset.height);
        selectionRectangleBorderRect = NSInsetRect(NSUnionRect(selectionRectangleBorderRect, [selectionRectanglePath bounds]), -1, -1);
        
        NSBezierPath* selectionRectangleNegativePath = [NSBezierPath bezierPathWithRect: selectionRectangleBorderRect];
        [selectionRectangleNegativePath appendBezierPath: selectionRectanglePath];
        [selectionRectangleNegativePath setWindingRule: NSEvenOddWindingRule];
        
        [NSGraphicsContext saveGraphicsState];
        {
            NSShadow* highlightShadowWithOffset = [highlightShadow copy];
            CGFloat xOffset = highlightShadowWithOffset.shadowOffset.width + round(selectionRectangleBorderRect.size.width);
            CGFloat yOffset = highlightShadowWithOffset.shadowOffset.height;
            highlightShadowWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
            [highlightShadowWithOffset set];
            [[NSColor grayColor] setFill];
            [selectionRectanglePath addClip];
            NSAffineTransform* transform = [NSAffineTransform transform];
            [transform translateXBy: -round(selectionRectangleBorderRect.size.width) yBy: 0];
            [[transform transformBezierPath: selectionRectangleNegativePath] fill];
        }
        [NSGraphicsContext restoreGraphicsState];
        
        [NSGraphicsContext restoreGraphicsState];
    }
    
    
    if (item.image)
    {
        //// imageRectangle Drawing
        [NSGraphicsContext saveGraphicsState];
        [backgroundShadow set];
        CGContextBeginTransparencyLayer(context, NULL);
        //[gradient drawInBezierPath: imageRectanglePath angle: -90];
        
        // image Drawing code here.
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        CGRect imageRect = CGRectMake(0, 0, item.image.size.width, item.image.size.height);
        NSRect imageRectangleFromPath = NSMakeRect(34, 51, 134, 134);
        CGRect drawRect = GTMCGScaleRectangleToSize(imageRect, imageRectangleFromPath.size, GTMScaleProportionally);
        NSRect centeredRect = NSIntegralRect([item.image centerRect:drawRect inRect:imageRectangleFromPath]);
        centeredRect.origin.x += 34;
        centeredRect.origin.y += 51;
        [item.image drawInRect:centeredRect fromRect:imageRect operation:NSCompositeCopy fraction:1.0];
        
        
        CGContextEndTransparencyLayer(context);
        
        NSRect rect = centeredRect;
        rect.origin.x += 0.5;
        rect.origin.y += 0.5;
        rect.size.width -= 1;
        rect.size.height -= 1;
        NSBezierPath* rectanglePath = [NSBezierPath bezierPathWithRect:rect];
        [[NSColor blackColor] setStroke];
        [rectanglePath setLineWidth: 1];
        [rectanglePath stroke];
        
        NSBezierPath *line = [NSBezierPath bezierPath];
        [line moveToPoint:NSMakePoint(centeredRect.origin.x + 1, centeredRect.origin.y + (centeredRect.size.height - 1.5))];
        [line lineToPoint:NSMakePoint(centeredRect.origin.x + (centeredRect.size.width - 1), centeredRect.origin.y + (centeredRect.size.height - 1.5))];
        [line setLineWidth:1.0]; /// Make it easy to see
        [[NSColor colorWithCalibratedWhite:1.0 alpha:0.25] set]; /// Make future drawing the color of lineColor.
        [line stroke];
        
        [NSGraphicsContext restoreGraphicsState];
    }
    
    //// nameText Drawing
    NSRect nameTextRect = NSMakeRect(10, 22, 182, 20);
    [NSGraphicsContext saveGraphicsState];
    [textShadow set];
    NSMutableParagraphStyle* nameTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [nameTextStyle setAlignment: NSCenterTextAlignment];
    [nameTextStyle setLineBreakMode:NSLineBreakByTruncatingTail];

    
    NSDictionary* nameTextFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSFont controlContentFontOfSize: [NSFont systemFontSize]], NSFontAttributeName,
                                            nameTextColor, NSForegroundColorAttributeName,
                                            nameTextStyle, NSParagraphStyleAttributeName, nil];
    
    [nameTextContent drawInRect: nameTextRect withAttributes: nameTextFontAttributes];
    [NSGraphicsContext restoreGraphicsState];
    
    
    
    //// subtitleText Drawing
    NSRect subtitleTextRect = NSMakeRect(10, 3, 182, 20);
    [NSGraphicsContext saveGraphicsState];
    [textShadow set];
    NSMutableParagraphStyle* subtitleTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [subtitleTextStyle setAlignment: NSCenterTextAlignment];
    [subtitleTextStyle setLineBreakMode:NSLineBreakByTruncatingTail];

    NSDictionary* subtitleTextFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSFont controlContentFontOfSize: [NSFont smallSystemFontSize]], NSFontAttributeName,
                                                subtitleColor, NSForegroundColorAttributeName,
                                                subtitleTextStyle, NSParagraphStyleAttributeName, nil];
    
    [subtitleTextContent drawInRect: subtitleTextRect withAttributes: subtitleTextFontAttributes];
    [NSGraphicsContext restoreGraphicsState];

}*/

@end

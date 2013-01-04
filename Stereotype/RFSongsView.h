//
//  RFSongsView.h
//  Stereotype
//
//  Created by brandon on 12/18/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import "RFLibraryView.h"

typedef enum
{
    RFSongsViewStylePlaylist = 0,
    RFSongsViewStyleAllSongs,
    RFSongsViewStyleAlbum,
    RFSongsViewStyleArtist
} RFSongsViewStyle;

@interface RFSongsView : RFLibraryView

@property (nonatomic, strong) RFPlaylistEntity *playlist;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, assign) RFSongsViewStyle viewStyle;

- (void)loadAllSongs;

@end

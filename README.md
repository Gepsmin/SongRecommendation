# Song Recommendation System using Prolog
This project has tousands of songs, albums and artists as knowledge base. These knowledge base gathered using SpotifyAPI.(Look for more information: https://developer.spotify.com/). It is a recommendation system to find artists, albums and songs similar to another. Also you can find your best 30 songs entering your liked genres, disliked genres, and features of desired song. (But this project is primitive type of recommendation system and an experimantal tool to find out how we can use our knowledge bases.)

### Prerequisites
Prolog. 
I used SWI-Prolog to implement this project. Also you can install via this address.
```
https://www.swi-prolog.org/Download.html
```

### Installing
After you downloaded it using terminal go to same directory with the project.
To open the knowledge base and swi prolog:
```
swipl load.pl
```
It loads the tracks.pl, albums.pl, artists.pl
After to use recommendation system type:
```
[recommendation]
```
## Predicates
There are some predicates that might be usefull to find songs.

### getArtistTracks(+ArtistName, -TrackIds, -TrackNames)
This predicate gives ids and names of the artist's songs.

```
getArtistTracks("Gorillaz", TrackIds, TrackNames). 
```

### albumFeatures(+AlbumId, -AlbumFeatures)
This predicate gives album features. Album feature is the average of the features of its tracks

```
albumFeatures("0cn6MHyx4YuZauaB7Pb66o", AlbumFeatures).
```

### artistFeatures(+ArtistName, -ArtistFeatures)
This predicate gives artist features. Artist features is the average of the features of its tracks.

```
artistFeatures("Tarkan", ArtistFeatures).
```

### findMostSimilarTracks(+TrackId, -SimilarIds, -SimilarNames)
When entered a track id, it returns top 30 closest tracks' ids and names in order.

```
findMostSimilarTracks("1FOernT6bFAm8zscEss4Sm", SimilarIds, SimilarNames). 
```

### findMostSimilarAlbums(+AlbumId, -SimilarIds, -SimilarNames)
When entered an album id, it returns top 30 closest albums' ids and names in order.

```
findMostSimilarAlbums("32fmr8WaoHl7XJXnlzyVyX", SimilarIds, SimilarNames).
```

### findMostSimilarArtists(+ArtistName, -SimilarArtists)
When entered an artist name, it returns top 30 closest artists' names in order.

```
findMostSimilarArtists("deadmau5", SimilarArtists).
```

### discoverPlaylist(+LikedGenres, +DislikedGenres, +Features, +FileName, -Playlist)
It is the main predicate. It finds out the 30 closest tracks to given features. This 30 tracks includes at least one of the liked genres and don't includes any of the disliked genres. It writes the all outputs to given +FileName in the following format.
    [trackid1,trackid2,trackid3,...,trackid30]
    [trackname1,trackname2,trackname3,...,trackname30]
    [artists1,artist2,artists3,...,artists30]
    [distance1,distance2,distance3,...,distance30]

```
discoverPlaylist(["pop", "blues"], ["classic"], [0.6, 0.2, 0.3, 0.4, 0.7, 0.2, 0.5, 0.5], "popblues.txt", Playlist).
artistFeatures("Metallica", F), discoverPlaylist(["metal"], ["rock"], F, "likemetallica.txt", Playlist).
discoverPlaylist(["birmingham metal"], [], [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5], "ozzy.txt", Playlist).
```

## P.S
The knowledge base doesn't include every song or artist. So you may not found wanted song or artist. Actually the knowledge base doesn't include artists' all songs or albums either. It is restricted even if there is tousands of songs. 
Also you can find another usefell predicates in recommendation.pl

## Author

* **Onur Sefa Özçıbık** - [Gepsmin](https://github.com/Gepsmin)
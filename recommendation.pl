%finds AlbumIds of an Artist
getArtistAlbumIds(Artistname, Albumids) :- artist(Artistname,_ ,Albumids).


%obtain the AlbumNames from AlbumIds
getAlbumNamesFromAlbumIds([], []).
getAlbumNamesFromAlbumIds([Head|Tail], Result) :- 
    getAlbumNamesFromAlbumIds(Tail, Result1),
    findall(X, album(Head,X,_,_ ), List),
    append(List, Result1, Result).

%Finds AlbumIds from ArtistNames, then finds AlbumNames from these AlbumIds
getArtistAlbumnames(Name, Result) :- getArtistAlbumIds(Name, X) , getAlbumNamesFromAlbumIds(X, Result).

%Puts together the TrackIds which found with the AlbumName information.
getTrackidsFromAlbumnames([], []).
getTrackidsFromAlbumnames([Head|Tail], Tracklist) :-
    getTrackidsFromAlbumnames(Tail, Tracklist1),
    findall(X, track(X, _,_,Head,_),List),
    append(List, Tracklist1, Tracklist).

%Puts together the TrackNames which found with the AlbumName information.
getTracknamesFromAlbumnames([], []).
getTracknamesFromAlbumnames([Head|Tail], Tracklist) :-
    getTracknamesFromAlbumnames(Tail, Tracklist1),
    findall(X, track(_, X,_,Head,_),List),
    append(List, Tracklist1, Tracklist).    

%Gather helper predicates to Find the All Tracks that published by one Artist
getArtistTracks(Artist, Trackids, Tracknames) :-
    getArtistAlbumnames(Artist, Albumnames),
    getTrackidsFromAlbumnames(Albumnames, Trackids),
    getTracknamesFromAlbumnames(Albumnames, Tracknames).




% albumFeatures(+AlbumId, -AlbumFeatures) 5 points

%Tracks have unwanted features. So we obtain wanted parts of it.
getWanted([_,A,B,_,_,C,D,E,F,G,H,_,_,_],[A,B,C,D,E,F,G,H]):-!.
 
%It adds list elements that are in the same index and constructs another one.
topla([],[],[]) :- !.
topla([Head|Tail],[],[Head|Tail]) :-!.
topla([Head1|Tail1], [Head2|Tail2], [X|Y]) :-
    X is Head1 + Head2,
    topla(Tail1, Tail2, Y).


%It applies topla predicate recursivly to add more than 2 list.
rec_topla([],[]) :- !.
rec_topla([Head],Head) :- !. 
rec_topla([Head,Tail],Result) :-
    topla(Head,Tail,Result), !.
rec_topla([Head|Tail], Result) :-
    rec_topla(Tail,Result1),
    topla(Head,Result1,Result), !.


%Divides every element of a list. It designed to take average.
avarage([],_,[]) :- !.
avarage([Head|Tail], N, [Rhead|Rtail]) :-
    Rhead is Head / N,
    avarage(Tail, N, Rtail).

%It is an attempt to take albumFeatures but didn't end very well
albumF(Albumid, Result) :-
    album(Albumid,Albumname,_,_),
    findall(X , (track(_,_,_,Albumname,Y), getWanted(Y,X)), Featurelist),
    length(Featurelist, N),
    rec_topla(Featurelist,Total),
    avarage(Total,N,Result).

%First adds all Track Features in an Album then takes the average of it.
albumFeatures(Albumid, Result) :-
    album(Albumid,_,_,Trackids),
    totalTrackFeatures(Trackids, Total),
    length(Trackids, N),
    avarage(Total, N, Result).

%adds all wanted Track Features 
totalTrackFeatures([], []) :- !.
totalTrackFeatures([Head|Tail], Total) :-
    track(Head,_,_,_,Features),
    getWanted(Features, Wantedfeatures),
    totalTrackFeatures(Tail, Total1),
    topla(Wantedfeatures, Total1, Total).
% artistFeatures(+ArtistName, -ArtistFeatures) 5 points

%Gathers all tracks from all Albums that belong to one artist
getAllTracks([],[]) :- !.
getAllTracks([Head|Tail], Trackids):-
    album(Head,_,_,Tracks),
    getAllTracks(Tail, Tracks1),
    append(Tracks, Tracks1, Trackids).

%Finds feature average of all tracks by first finding the total features and then taking the average of it.
artistFeatures(Artistname, ArtistFeatures) :-
    artist(Artistname, _, Albumids),
    getAllTracks(Albumids, Trackids),
    totalTrackFeatures(Trackids, Total),
    length(Trackids, N),
    avarage(Total, N, ArtistFeatures).


% trackDistance(+TrackId1, +TrackId2, -Score) 5 points

%helps to find out the euclidean distance by adding all feature squares.
euclideanHelper([],[], 0) :- !.
euclideanHelper([X], [Y], Square) :-
    Difference is X - Y,
    Square is Difference * Difference, !.
euclideanHelper([X|Xtail], [Y|Ytail], Total) :-
    euclideanHelper(Xtail, Ytail, Total1),
    Difference is X - Y,
    Square is Difference * Difference,
    Total is Square + Total1, !.
%after euclideanHelper predicate it just needs to find the square root of the result to find euclidean distance
euclideanDistance(X, Y , Distance) :- 
    euclideanHelper(X, Y, Total),
    Distance is sqrt(Total).

%Takes track features then finds the euclidean distance by using helper predicates
trackDistance(Trackid1, Trackid2, Score) :-
    track(Trackid1,_,_,_,Feature1),
    track(Trackid2,_,_,_,Feature2),
    getWanted(Feature1, F1),
    getWanted(Feature2, F2),
    euclideanDistance(F1, F2, Score), !.


% albumDistance(+AlbumId1, +AlbumId2, -Score) 5 points

%Similar to trackDistance, uses previous predicates to find euclidean distance of two albums
albumDistance(Albumid1, Albumid2, Score) :-
    albumFeatures(Albumid1, Feature1),
    albumFeatures(Albumid2, Feature2),
    euclideanDistance(Feature1, Feature2, Score).

% artistDistance(+ArtistName1, +ArtistName2, -Score) 5 points
%Similar to albumDistance, uses previous predicates to fing euclidean distance of two artists
artistDistance(Artistname1, Artistname2, Score) :-
    artistFeatures(Artistname1, Feature1),
    artistFeatures(Artistname2, Feature2),
    euclideanDistance(Feature1, Feature2, Score).


% findMostSimilarTracks(+TrackId, -SimilarIds, -SimilarNames) 10 points
%It's a parser predicate to take seperate variables into different lists
ayir5([], [], [], [], []) :- !.
ayir5([X-I-N-A|Tail], Ids, Names, Artists, Dists) :-
    ayir5(Tail, Ids1, Names1, Artists1, Dists1),
    Ids = [I|Ids1],
    Names = [N|Names1],
    Artists = [A|Artists1],
    Dists = [X|Dists1], !.

%It's a parser predicate to take seperate variables into different lists
ayir([], [], []) :- !.
ayir([_-I-N|Tail],Ids, Names) :-
    ayir(Tail,Ids1, Names1),
    Ids = [I|Ids1],
    Names = [N|Names1], !.

%Gathers first n element of a list
firstHelper([],[],_):- !.
firstHelper(_,[],0) :- !.
firstHelper([Head|Tail],Result, N) :-
    N > 0,
    Next is N -1,
    firstHelper(Tail, Result1, Next),
    Result = [Head|Result1], !.

%Uses previous predicate to gather first 30 element of a list
first30(List,Neulist) :-
    firstHelper(List, Neulist, 30), !.

%Takes all tracks, calculates the distances, sorts them, takes first 30 tracks then parses them.
findMostSimilarTracks(Trackid, Similarids, Similarnames) :-
    findall(X-I-N, (track(I,N,_,_,_),Trackid\=I, trackDistance(Trackid, I, X)), Tracks),
    sort(Tracks, Sortedtracks),
    first30(Sortedtracks, Sortedfirst30),
    ayir(Sortedfirst30, Similarids, Similarnames), !.



% findMostSimilarAlbums(+AlbumId, -SimilarIds, -SimilarNames) 10 points
%Takes all albums, calculates the distances, sorts them, takes the first 30 albums then parses them.
findMostSimilarAlbums(Albumid, Similarids, Similarnames) :-
    findall(X-I-N, (album(I, N, _, _), I\=Albumid, albumDistance(Albumid, I, X)), Albums),
    sort(Albums, Sortedalbums),
    first30(Sortedalbums, Sortedfirst30),
    ayir(Sortedfirst30, Similarids, Similarnames), !.

% findMostSimilarArtists(+ArtistName, -SimilarArtists) 10 points

%It's a parser predicate to take seperate variables into different lists
ayir2([],[]) :- !.
ayir2([_-N|Tail],Ns) :-
    ayir2(Tail, Ns1),
    Ns = [N|Ns1], !.

%Takes all artists, calculates the distances, sorts them, takes the first 30 artists then parses them.
findMostSimilarArtists(Artistname, Similarartists) :-
    findall(X-N, (artist(N, _ , _), N\= Artistname, artistDistance(Artistname, N, X)), Artists),
    sort(Artists, Sortedartists),
    first30(Sortedartists, Sortedfirst30),
    ayir2(Sortedfirst30, Similarartists), !.

% filterExplicitTracks(+TrackList, -FilteredTracks) 5 points
%Checks wheter a tracks has the explicity feature in it or not. 
filterExplicitTracks([], []) :-!.
filterExplicitTracks([Head|Tail], Filtered) :-
    filterExplicitTracks(Tail, Filtered1),
    track(Head,_,_,_, [Explicit|_]),
    Explicit \= 1,
    Filtered = [Head|Filtered1],!.
filterExplicitTracks([Head|Tail], Filtered) :-
    filterExplicitTracks(Tail, Filtered),
    track(Head,_,_,_,[Explicit|_]),
    Explicit == 1,!.



% getTrackGenre(+TrackId, -Genres) 5 points
%By trackId, reaches the songs artists, then takes the genre information from them.
getTrackGenre(Trackid, Genres):-
    track(Trackid,_,Artistnames,_,_),
    getGenresFromArtistnames(Artistnames,Genres),!.
getGenresFromArtistnames([],[]) :- !.
getGenresFromArtistnames([Head],Genres) :-
    artist(Head, Genres, _),!.
getGenresFromArtistnames([Head|Tail], Genres) :-
    getGenresFromArtistnames(Tail, Genres1),
    artist(Head,Genres2,_),
    append(Genres1, Genres2, List),
    list_to_set(List, Genres),!.


% discoverPlaylist(+LikedGenres, +DislikedGenres, +Features, +FileName, -Playlist) 30 points
%I didn't use them but i want them in here as monument to show how badly an idea can be interpereted
getGenreTracks([], []) :- !.
getGenreTracks(Genrelist, Result):-
    findall(I-N-A-F, (
            track(I,N,A,_,F),
            getTrackGenre(I, Genres),
            member(Member, Genres),
            member(Glmember, Genrelist),
            sub_atom(Member,_,_,_,Glmember)
            ), Result
        ).

takeDifference(X,[],X) :- !.
takeDifference([], _, []) :- !.
takeDifference(List1, List2, Result) :-
    findall(X, (member(X,List1), \+member(X,List2)), Result).
%yep until now, i didn't use this stupidity


%Finds all tracks, calculates the distances, sorts them, takes first 30 of it while checking the genres, then parses them. 
discoverPlaylist(Likedgenres, Dislikedgenres, Features, Filename, Playlist) :-
%    getGenreTracks(Likedgenres, Likedtracks),
%    getGenreTracks(Dislikedgenres, Dislikedtracks),
%    takeDifference(Likedtracks, Dislikedtracks, Alltracks),
%    getAllWantedTracks(Likedgenres, Dislikedgenres, Alltracks),
    findall(X-I-N-A, (track(I,N,A,_,F),getWanted(F, Fwanted),
            euclideanDistance(Features, Fwanted, X)), Tracks),
    sort(Tracks, Sortedtracks),
    firstWanted(Sortedtracks, Likedgenres, Dislikedgenres, Sortedfirst30), 
    ayir5(Sortedfirst30, Similarids, Similarnames, Artists, Distances),
    Playlist= Similarids,
    open(Filename, write, Stream), write(Stream, Similarids), nl(Stream), write(Stream, Similarnames), nl(Stream),
    write(Stream, Artists), nl(Stream), write(Stream, Distances), close(Stream), !.


%It uses helper predicate to take first 30 wanted track
firstWanted(Sortedtracks, Likedgenres, Dislikedgenres, Sortedfirst) :-
    fwHelper(Sortedtracks, Likedgenres, Dislikedgenres, Sortedfirst, 30).

%Takes the head of the list, checks if it has genre that liked or disliked, after logic operations decides to put it into first 30 element
%or not. If it puts an element to final list, it means that we want to find one less element now.
fwHelper([], _, _, [], _) :- !.
fwHelper(_, _, _, [], 0) :- !.
fwHelper([_-I-_-_|Tail], Liked, Disliked, Result, N) :-
    N > 0,
    getTrackGenre(I, Genres),
    getCode(Genres, Disliked, 0),
    fwHelper(Tail, Liked, Disliked, Result, N).
fwHelper([_-I-_-_|Tail], Liked, Disliked, Result, N) :-
    N > 0,
    getTrackGenre(I, Genres),
    getCode(Genres, Liked, 1),
    fwHelper(Tail, Liked, Disliked, Result, N).
fwHelper([X-I-N-A|Tail], Liked, Disliked, Result, C) :-
    C > 0,
    Next is C - 1,
    getTrackGenre(I, Genres),
    getCode(Genres, Liked, 0),
    getCode(Genres, Disliked, 1),
    fwHelper(Tail, Liked, Disliked, Result1, Next),
    Result = [X-I-N-A|Result1].

%Find outs G has an element which contain an element that is in D.
getCode(G, D, NeuCode) :-
    member(M , G),
    member(X, D),
    sub_atom(M,_,_,_,X)-> NeuCode is 0; NeuCode is 1.
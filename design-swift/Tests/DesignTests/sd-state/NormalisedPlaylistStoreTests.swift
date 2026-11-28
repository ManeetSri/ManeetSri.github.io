import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NormalisedPlaylistStoreTests {
    typealias Track = NormalisedPlaylistStore.Track
    typealias Payload = NormalisedPlaylistStore.PlaylistPayload

    let intro = Track(id: "t1", title: "Intro", seconds: 90)
    let anthem = Track(id: "t2", title: "Anthem", seconds: 240)
    let ballad = Track(id: "t3", title: "Ballad", seconds: 300)

    /// Two playlists that share the anthem, as the server sends them
    private func library() -> NormalisedPlaylistStore.Library {
        var library = NormalisedPlaylistStore.Library()
        library.ingest(Payload(id: "run", name: "Running", tracks: [intro, anthem]))
        library.ingest(Payload(id: "chill", name: "Chill", tracks: [ballad, anthem]))
        return library
    }

    @Test("Ingesting nested playlists stores each track once and each playlist as ids in order")
    func ingest() {
        let library = library()
        #expect(library.tracks.count == 3)
        #expect(library.playlistTrackIDs["run"] == ["t1", "t2"])
        #expect(library.playlistTrackIDs["chill"] == ["t3", "t2"])
        #expect(library.playlistNames == ["run": "Running", "chill": "Chill"])
        #expect(library.tracks(inPlaylist: "chill") == [ballad, anthem])
    }

    @Test("Changing a track once changes it in every playlist")
    func oneChangeEverywhere() {
        var library = library()
        let renamed = Track(id: "t2", title: "Anthem (Live)", seconds: 255, version: 2)
        library.update(renamed)
        #expect(library.tracks(inPlaylist: "run").last == renamed)
        #expect(library.tracks(inPlaylist: "chill").last == renamed)
    }

    @Test("Totals are derived, so they follow every change")
    func derivedTotals() {
        var library = library()
        #expect(library.totalSeconds(ofPlaylist: "run") == 330)
        #expect(library.totalSeconds(ofPlaylist: "chill") == 540)

        library.update(Track(id: "t2", title: "Anthem (Radio Edit)", seconds: 180, version: 2))
        #expect(library.totalSeconds(ofPlaylist: "run") == 270)
        #expect(library.totalSeconds(ofPlaylist: "chill") == 480)
        #expect(library.totalSeconds(ofPlaylist: "missing") == 0)
    }

    @Test("An older copy of a track never replaces a newer one")
    func versions() {
        var library = library()
        library.update(Track(id: "t1", title: "Intro (Remastered)", seconds: 95, version: 3))
        library.update(Track(id: "t1", title: "Intro (Demo)", seconds: 60, version: 2))
        #expect(library.tracks["t1"]?.title == "Intro (Remastered)")

        // A cached payload arriving late still carries version 1 of the intro
        library.ingest(Payload(id: "run", name: "Running", tracks: [intro, anthem]))
        #expect(library.tracks["t1"]?.version == 3)
        #expect(library.totalSeconds(ofPlaylist: "run") == 335)
    }

    @Test("A copy with the same version replaces the stored one")
    func sameVersion() {
        var library = library()
        library.update(Track(id: "t3", title: "Ballad", seconds: 301))
        #expect(library.tracks["t3"]?.seconds == 301)
    }

    @Test("Ingesting a playlist again replaces its name and order")
    func reingest() {
        var library = library()
        library.ingest(Payload(id: "run", name: "Morning run", tracks: [anthem, ballad, intro]))
        #expect(library.playlistNames["run"] == "Morning run")
        #expect(library.tracks(inPlaylist: "run").map(\.id) == ["t2", "t3", "t1"])
        #expect(library.tracks.count == 3)
    }

    @Test("Removing a track removes it from the library and from every playlist")
    func remove() {
        var library = library()
        library.ingest(Payload(id: "loop", name: "On repeat", tracks: [anthem, intro, anthem]))
        library.removeTrack(id: "t2")
        #expect(library.tracks["t2"] == nil)
        #expect(library.playlistTrackIDs["run"] == ["t1"])
        #expect(library.playlistTrackIDs["chill"] == ["t3"])
        #expect(library.playlistTrackIDs["loop"] == ["t1"])
        #expect(library.playlists(containingTrack: "t2").isEmpty)
    }

    @Test("Which playlists contain a track is derived from the ids, sorted")
    func membership() {
        var library = library()
        #expect(library.playlists(containingTrack: "t2") == ["chill", "run"])
        #expect(library.playlists(containingTrack: "t1") == ["run"])
        library.ingest(Payload(id: "all", name: "Everything", tracks: [intro, anthem, ballad]))
        #expect(library.playlists(containingTrack: "t1") == ["all", "run"])
    }
}

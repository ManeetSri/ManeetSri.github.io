// Generated from src/dsa/design/content/lessons/sd-modelling/sd-modelling-information-hiding.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct Track: Hashable {
    let id: String
    let title: String
    let seconds: Int
}

/// A playlist the user builds. Its rules: no track twice, and at most 500 tracks.
struct Playlist {
    static let maxTracks = 500

    enum Problem: Error {
        case alreadyAdded(String)
        case full
    }

    let name: String
    private(set) var tracks: [Track] = []

    init(name: String) {
        self.name = name
    }

    mutating func add(_ track: Track) throws {
        guard !tracks.contains(track) else { throw Problem.alreadyAdded(track.title) }
        guard tracks.count < Self.maxTracks else { throw Problem.full }
        tracks.append(track)
    }

    mutating func remove(_ track: Track) {
        tracks.removeAll { $0 == track }
    }

    // Derived, not stored, so it can never disagree with the tracks
    var duration: Duration {
        .seconds(tracks.reduce(0) { $0 + $1.seconds })
    }
}

let intro = Track(id: "t1", title: "Warm-up", seconds: 245)
let tempo = Track(id: "t2", title: "Tempo", seconds: 180)

var run = Playlist(name: "Morning run")
try run.add(intro)
try run.add(tempo)
do {
    try run.add(intro)
} catch {
    print("Refused: \(error)")
}
print("\(run.name): \(run.tracks.map(\.title)), \(run.duration.formatted(.time(pattern: .minuteSecond)))")
run.remove(intro)
print("After removing: \(run.tracks.map(\.title))")

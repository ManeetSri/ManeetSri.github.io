// Kata: Normalised playlist store (D19 · Normalisation and identity; Derived state)
import Foundation

public enum NormalisedPlaylistStore {
    public struct Track: Equatable, Sendable {
        public let id: String
        public var title: String
        public var seconds: Int
        /// The server bumps this on every change to the track, so a higher version is newer
        public var version: Int

        public init(id: String, title: String, seconds: Int, version: Int = 1) {
            self.id = id
            self.title = title
            self.seconds = seconds
            self.version = version
        }
    }

    /// A playlist as the server sends it, with its tracks nested inside, in order
    public struct PlaylistPayload: Sendable {
        public let id: String
        public let name: String
        public let tracks: [Track]

        public init(id: String, name: String, tracks: [Track]) {
            self.id = id
            self.name = name
            self.tracks = tracks
        }
    }

    /// Every track stored once, by id. Playlists hold only track ids; everything else is derived.
    public struct Library: Sendable {
        public private(set) var tracks: [String: Track] = [:]
        public private(set) var playlistNames: [String: String] = [:]
        /// Each playlist's track ids, in play order. A track may appear more than once.
        public private(set) var playlistTrackIDs: [String: [String]] = [:]

        public init() {}

        /// Stores a playlist from the server: its name and order replace what was there, and each
        /// track is stored once, keeping whichever copy has the higher version
        public mutating func ingest(_ payload: PlaylistPayload) {
            // Write your solution here, then run:
            // swift test --filter NormalisedPlaylistStoreTests
        }

        /// Stores one changed track, unless the library already has a newer version of it
        public mutating func update(_ track: Track) {}

        /// Removes a track from the library and from every playlist that contains it
        public mutating func removeTrack(id: String) {}

        /// The playlist's tracks, in play order; empty for a playlist the library doesn't have
        public func tracks(inPlaylist id: String) -> [Track] { [] }

        /// How long the playlist plays for, in seconds
        public func totalSeconds(ofPlaylist id: String) -> Int { 0 }

        /// The ids of every playlist that contains the track, sorted
        public func playlists(containingTrack id: String) -> [String] { [] }
    }
}

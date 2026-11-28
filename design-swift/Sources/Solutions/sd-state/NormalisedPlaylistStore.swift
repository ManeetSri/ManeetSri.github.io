// Reference solution: Normalised playlist store. Nested payloads are split into one table of tracks by
// id and, per playlist, an ordered list of ids. A track changes in exactly one place, so every playlist
// sees the change; totals and memberships are computed from the tables when asked, never stored.
import Foundation

public enum NormalisedPlaylistStore {
    public struct Track: Equatable, Sendable {
        public let id: String
        public var title: String
        public var seconds: Int
        public var version: Int

        public init(id: String, title: String, seconds: Int, version: Int = 1) {
            self.id = id
            self.title = title
            self.seconds = seconds
            self.version = version
        }
    }

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

    public struct Library: Sendable {
        public private(set) var tracks: [String: Track] = [:]
        public private(set) var playlistNames: [String: String] = [:]
        public private(set) var playlistTrackIDs: [String: [String]] = [:]

        public init() {}

        public mutating func ingest(_ payload: PlaylistPayload) {
            payload.tracks.forEach { update($0) }
            playlistNames[payload.id] = payload.name
            playlistTrackIDs[payload.id] = payload.tracks.map(\.id)
        }

        public mutating func update(_ track: Track) {
            if let stored = tracks[track.id], stored.version > track.version { return }
            tracks[track.id] = track
        }

        public mutating func removeTrack(id: String) {
            tracks[id] = nil
            for playlist in playlistTrackIDs.keys {
                playlistTrackIDs[playlist]?.removeAll { $0 == id }
            }
        }

        public func tracks(inPlaylist id: String) -> [Track] {
            (playlistTrackIDs[id] ?? []).compactMap { tracks[$0] }
        }

        public func totalSeconds(ofPlaylist id: String) -> Int {
            tracks(inPlaylist: id).reduce(0) { $0 + $1.seconds }
        }

        public func playlists(containingTrack id: String) -> [String] {
            playlistTrackIDs.filter { $0.value.contains(id) }.keys.sorted()
        }
    }
}

// Problem: Shuffle with pinned songs (M67 · Fisher–Yates and shuffle())

public enum PinnedPlaylistShuffle {
    /// Returns a new order of `songs` in which every position in `pinned` keeps its song, and the
    /// other songs are arranged uniformly at random. Draw every random number from `generator`, and
    /// write the shuffle yourself (Fisher–Yates) rather than calling shuffle().
    public static func shuffled(_ songs: [String], pinned: Set<Int>, using generator: inout some RandomNumberGenerator) -> [String] {
        // Write your solution here, then run:
        // swift test --filter PinnedPlaylistShuffleTests
        return []
    }
}

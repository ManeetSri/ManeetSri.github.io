// Reference solution: Shuffle with pinned songs. Fisher–Yates over the unpinned positions only: list
// them in order as `free`, then for t from the last down to 1, swap the song at free[t] with the song
// at free[u] for u uniform in 0...t. That makes m! equally likely choice sequences for the m free
// songs, one per arrangement. O(n) time, O(n) space for the result and the free list.

public enum PinnedPlaylistShuffle {
    public static func shuffled(_ songs: [String], pinned: Set<Int>, using generator: inout some RandomNumberGenerator) -> [String] {
        var result = songs
        let free = songs.indices.filter { !pinned.contains($0) }
        guard free.count > 1 else { return result }
        for t in stride(from: free.count - 1, through: 1, by: -1) {
            let u = Int.random(in: 0...t, using: &generator)   // including t: the song may stay
            result.swapAt(free[t], free[u])
        }
        return result
    }
}

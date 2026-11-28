// Reference solution: Counting fence posts. A straight fence has one more post than gaps; a closed
// pen reuses its first post, so it has exactly as many posts as metres. O(1) time and space.

public enum FencePostCount {
    public static func straight(metres: Int) -> Int {
        return metres + 1 // each metre is a gap between two posts, so there's one post more than metres
    }

    public static func closedPen(length: Int, width: Int) -> Int {
        // The fence ends where it started, so the last gap reuses the first post: posts = metres round.
        return 2 * (length + width)
    }
}

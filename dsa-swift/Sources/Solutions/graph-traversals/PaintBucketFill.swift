// Reference solution: Paint bucket fill. A flood fill from the clicked pixel with an explicit stack
// (an iterative DFS), so a huge snake-shaped region can't overflow the call stack. Each pixel is
// repainted the moment it's pushed, which doubles as its visited mark. If the new colour equals the
// old one there's nothing to do, and returning early also stops the fill from looping forever.
// O(rows × columns) time and space.

public enum PaintBucketFill {
    private static let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

    public static func fill(_ image: [[Int]], row: Int, column: Int, with colour: Int) -> [[Int]] {
        var image = image
        let original = image[row][column]
        if original == colour { return image }
        image[row][column] = colour
        var stack = [(row, column)]
        while let cell = stack.popLast() {
            for (dr, dc) in directions {
                let r = cell.0 + dr
                let c = cell.1 + dc
                guard r >= 0, r < image.count, c >= 0, c < image[r].count else { continue }
                guard image[r][c] == original else { continue }
                image[r][c] = colour                     // repaint as it's pushed: never pushed twice
                stack.append((r, c))
            }
        }
        return image
    }
}

// Reference solution: Tower of Hanoi moves. To move n disks, move n − 1 out of the way, move the
// largest, then move the n − 1 back on top. That's 2ⁿ − 1 moves, so O(2ⁿ) time, which is unavoidable
// because every move has to be listed, and O(n) stack space.

public enum HanoiMoves {
    public struct Move: Equatable, CustomStringConvertible {
        public let disk: Int
        public let from: Int
        public let to: Int

        public init(disk: Int, from: Int, to: Int) {
            self.disk = disk
            self.from = from
            self.to = to
        }

        public var description: String { "disk \(disk): \(from) → \(to)" }
    }

    public static func moves(disks: Int) -> [Move] {
        var result: [Move] = []
        func solve(_ n: Int, from: Int, to: Int, via: Int) {
            if n == 0 {
                return                                      // nothing to move
            }
            solve(n - 1, from: from, to: via, via: to)      // clear the way
            result.append(Move(disk: n, from: from, to: to))
            solve(n - 1, from: via, to: to, via: from)      // stack them back on top
        }
        solve(disks, from: 1, to: 3, via: 2)
        return result
    }
}

// Problem: Tower of Hanoi moves (M17 · Multiple recursion and exponential blow-up)

public enum HanoiMoves {
    /// One move: take disk `disk` off the top of peg `from` and put it on peg `to`.
    /// Disks are numbered from 1 (the smallest) upwards; pegs are numbered 1, 2 and 3.
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

    /// The shortest list of legal moves that carries a stack of `disks` disks from peg 1 to peg 3.
    public static func moves(disks: Int) -> [Move] {
        // Write your solution here, then run:
        // swift test --filter HanoiMovesTests
        return []
    }
}

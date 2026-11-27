import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct HanoiMovesTests {
    typealias Move = HanoiMoves.Move

    /// Plays the moves on three pegs and returns the pegs at the end, or nil if any move is illegal.
    /// Each peg lists its disks from bottom to top.
    func play(_ moves: [Move], disks: Int) -> [[Int]]? {
        var pegs: [[Int]] = [Array(stride(from: disks, to: 0, by: -1)), [], []]
        for move in moves {
            guard (1...3).contains(move.from), (1...3).contains(move.to), move.from != move.to else { return nil }
            guard pegs[move.from - 1].last == move.disk else { return nil }         // must be the top disk
            if let top = pegs[move.to - 1].last, top < move.disk { return nil }      // never on a smaller disk
            pegs[move.from - 1].removeLast()
            pegs[move.to - 1].append(move.disk)
        }
        return pegs
    }

    @Test("Zero disks need no moves")
    func zeroDisks() {
        #expect(HanoiMoves.moves(disks: 0) == [])
    }

    @Test("One disk moves straight across")
    func oneDisk() {
        #expect(HanoiMoves.moves(disks: 1) == [Move(disk: 1, from: 1, to: 3)])
    }

    @Test("Two disks use the middle peg")
    func twoDisks() {
        #expect(HanoiMoves.moves(disks: 2) == [
            Move(disk: 1, from: 1, to: 2),
            Move(disk: 2, from: 1, to: 3),
            Move(disk: 1, from: 2, to: 3),
        ])
    }

    @Test("Three disks take the classic seven moves")
    func threeDisks() {
        #expect(HanoiMoves.moves(disks: 3) == [
            Move(disk: 1, from: 1, to: 3),
            Move(disk: 2, from: 1, to: 2),
            Move(disk: 1, from: 3, to: 2),
            Move(disk: 3, from: 1, to: 3),
            Move(disk: 1, from: 2, to: 1),
            Move(disk: 2, from: 2, to: 3),
            Move(disk: 1, from: 1, to: 3),
        ])
    }

    @Test("Uses exactly 2ⁿ − 1 moves", arguments: Array(1...12))
    func moveCount(disks: Int) {
        #expect(HanoiMoves.moves(disks: disks).count == (1 << disks) - 1)
    }

    @Test("Every move is legal and every disk ends on peg 3", arguments: Array(1...10))
    func legalAndComplete(disks: Int) throws {
        let moves = HanoiMoves.moves(disks: disks)
        let pegs = try #require(play(moves, disks: disks))
        #expect(pegs[0].isEmpty)
        #expect(pegs[1].isEmpty)
        #expect(pegs[2] == Array((1...disks).reversed()))
    }

    @Test("The largest disk moves exactly once")
    func largestMovesOnce() {
        let moves = HanoiMoves.moves(disks: 8)
        #expect(moves.filter { $0.disk == 8 } == [Move(disk: 8, from: 1, to: 3)])
        #expect(moves.filter { $0.disk == 1 }.count == 128)
    }

    @Test("Handles 16 disks")
    func sixteenDisks() throws {
        let moves = HanoiMoves.moves(disks: 16)
        #expect(moves.count == 65_535)
        let pegs = try #require(play(moves, disks: 16))
        #expect(pegs[2] == Array((1...16).reversed()))
    }
}

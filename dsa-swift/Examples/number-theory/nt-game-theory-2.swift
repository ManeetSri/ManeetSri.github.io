// Generated from src/dsa/content/lessons/number-theory/nt-game-theory.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Nim: the player to move wins exactly when the XOR of the piles isn't 0
func winningMove(_ piles: [Int]) -> (pile: Int, take: Int)? {
    let total = piles.reduce(0, ^)
    if total == 0 { return nil }                     // every move hands the opponent a non-zero XOR
    for (i, pile) in piles.enumerated() where pile ^ total < pile {
        return (i, pile - (pile ^ total))            // shrink this pile to pile ^ total
    }
    return nil                                       // unreachable: some pile has total's top bit
}

print([3, 4, 5].reduce(0, ^), winningMove([3, 4, 5])!)
print([1, 4, 5].reduce(0, ^), winningMove([1, 4, 5]) as Any)
print(winningMove([10, 7, 12, 2])!)

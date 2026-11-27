// Problem: Remove or split (M66 · Nim and Sprague–Grundy)

public enum PileSplitGame {
    /// Two players alternate. A move picks one pile and either removes exactly s stones for some s in
    /// `removals` (s no more than the pile), or splits it into two non-empty piles of different sizes.
    /// A player with no move loses. Returns whether the player to move first wins with perfect play.
    /// Up to 10,000 piles of 0 to 2,000 stones; up to 10 distinct removal sizes from 1 to 2,000.
    public static func firstPlayerWins(piles: [Int], removals: [Int]) -> Bool {
        // Write your solution here, then run:
        // swift test --filter PileSplitGameTests
        return false
    }
}

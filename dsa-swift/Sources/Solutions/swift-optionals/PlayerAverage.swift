// Reference solution: A player's average. One guard unwraps the lookup and rules out an empty list,
// then a loop adds up the scores. O(k) time for k scores, O(1) extra space.

public enum PlayerAverage {
    public static func average(for player: String, in scores: [String: [Int]]) -> Double? {
        guard let playerScores = scores[player], !playerScores.isEmpty else {
            return nil
        }
        var total = 0
        for score in playerScores {
            total += score
        }
        return Double(total) / Double(playerScores.count)
    }
}

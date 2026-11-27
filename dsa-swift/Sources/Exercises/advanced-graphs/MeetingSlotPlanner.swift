// Problem: Morning or afternoon (M47 · 2-SAT)

public enum MeetingSlotPlanner {
    /// A slot for each of `meetings` meetings, true for the morning and false for the afternoon, that
    /// keeps every rule, or nil if no plan does. A rule [a, b] says "a or b (or both)". A code x ≥ 0
    /// means "meeting x is in the morning" and ~x (that's -x - 1) means "meeting x is in the afternoon".
    public static func plan(_ meetings: Int, _ rules: [[Int]]) -> [Bool]? {
        // Write your solution here, then run:
        // swift test --filter MeetingSlotPlannerTests
        return nil
    }
}

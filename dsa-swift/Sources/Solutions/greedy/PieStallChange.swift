// Reference solution: Change at the pie stall. Count the 5s and 10s in the till. A 10 needs a 5 back.
// A 20 needs 15 back: a 10 and a 5 when possible, otherwise three 5s. Using the 10 keeps two extra 5s
// instead of a 10, and two 5s can do anything a 10 can, so the greedy till is never worse off.
// O(n) time, O(1) space.

public enum PieStallChange {
    public static func canGiveChange(_ payments: [Int]) -> Bool {
        var fives = 0
        var tens = 0
        for note in payments {
            switch note {
            case 5:
                fives += 1
            case 10:
                guard fives >= 1 else { return false }
                fives -= 1
                tens += 1
            case 20:
                if tens >= 1 && fives >= 1 {
                    tens -= 1
                    fives -= 1
                } else if fives >= 3 {
                    fives -= 3
                } else {
                    return false
                }
            default:
                return false            // not a note the stall accepts
            }
        }
        return true
    }
}

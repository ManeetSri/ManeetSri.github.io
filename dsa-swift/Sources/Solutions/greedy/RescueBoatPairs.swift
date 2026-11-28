// Reference solution: Rescue boats. Sort the weights. The heaviest person still waiting needs a boat:
// if the lightest person still waiting fits alongside them, nobody fits better, and swapping partners
// in any best plan shows pairing them is safe; if the lightest doesn't fit, nobody does, so the
// heaviest goes alone. Two pointers from the ends. O(n log n) time, O(n) space for the sorted copy.

public enum RescueBoatPairs {
    public static func boatsNeeded(_ weights: [Int], limit: Int) -> Int {
        let people = weights.sorted()
        var light = 0
        var heavy = people.count - 1
        var boats = 0
        while light <= heavy {
            if light < heavy && people[light] + people[heavy] <= limit {
                light += 1
            }
            heavy -= 1
            boats += 1
        }
        return boats
    }
}

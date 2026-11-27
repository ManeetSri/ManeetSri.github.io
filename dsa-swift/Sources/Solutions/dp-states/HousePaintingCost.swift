// Reference solution: Paint the houses. The state is the colour of the current house:
// best[c] = costs[i][c] + the cheapest previous total of any other colour. That's the previous row's
// lowest total, unless the lowest came from colour c itself, in which case the second lowest. One scan
// of the previous row finds both, so each house costs O(k). O(n · k) time, O(k) space.

public enum HousePaintingCost {
    public static func minimumCost(_ costs: [[Int]]) -> Int {
        guard var previous = costs.first else { return 0 }
        if previous.count == 1 {
            return costs.count == 1 ? previous[0] : -1        // one colour can't paint two neighbours
        }
        for house in costs.dropFirst() {
            var lowest = Int.max, secondLowest = Int.max, lowestColour = -1
            for (colour, total) in previous.enumerated() {
                if total < lowest {
                    (secondLowest, lowest, lowestColour) = (lowest, total, colour)
                } else if total < secondLowest {
                    secondLowest = total
                }
            }
            for colour in house.indices {
                previous[colour] = house[colour] + (colour == lowestColour ? secondLowest : lowest)
            }
        }
        return previous.min()!
    }
}

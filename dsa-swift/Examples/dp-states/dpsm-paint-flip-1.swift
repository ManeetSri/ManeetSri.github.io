// Generated from src/dsa/content/lessons/dp-states/dpsm-paint-flip.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let costs = [
    [7, 3, 8, 6],
    [5, 6, 2, 9],
    [4, 9, 6, 5],
    [8, 1, 7, 3],
]

// O(n · k²): for each colour, look at every other colour of the previous house
func cheapestSlow(_ costs: [[Int]]) -> Int {
    var previous = costs[0]
    for house in costs.dropFirst() {
        previous = house.indices.map { colour in
            house[colour] + previous.indices.filter { $0 != colour }.map { previous[$0] }.min()!
        }
    }
    return previous.min()!
}

// O(n · k): only the cheapest and second cheapest of the previous house can ever be needed
func cheapestFast(_ costs: [[Int]]) -> Int {
    var previous = costs[0]
    for house in costs.dropFirst() {
        var lowest = Int.max, secondLowest = Int.max, lowestColour = -1
        for (colour, total) in previous.enumerated() {
            if total < lowest {
                (secondLowest, lowest, lowestColour) = (lowest, total, colour)
            } else if total < secondLowest {
                secondLowest = total
            }
        }
        previous = house.enumerated().map { colour, cost in
            cost + (colour == lowestColour ? secondLowest : lowest)
        }
        print(previous)
    }
    return previous.min()!
}

print(cheapestSlow(costs))
print(cheapestFast(costs))

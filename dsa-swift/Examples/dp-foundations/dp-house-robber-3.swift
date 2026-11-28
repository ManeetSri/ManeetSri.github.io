// Generated from src/dsa/content/lessons/dp-foundations/dp-house-robber.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// House robber with two rolling variables
func rob(_ houses: ArraySlice<Int>) -> Int {
    var (twoBack, oneBack) = (0, 0)              // the best from the houses before the previous one, and before this one
    for value in houses {                        // no indexes, so a slice's indexes can't trip us up
        (twoBack, oneBack) = (oneBack, max(oneBack, twoBack + value))
    }
    return oneBack
}

/// The houses stand in a circle, so the first and last are neighbours
func robCircle(_ houses: [Int]) -> Int {
    if houses.count == 1 {
        return houses[0]
    }
    let firstLeftAlone = rob(houses.dropFirst())   // houses 1...n - 1
    let lastLeftAlone = rob(houses.dropLast())     // houses 0...n - 2
    return max(firstLeftAlone, lastLeftAlone)
}

let street = [5, 8, 6, 1, 2, 9]
print("in a row:", rob(street[...]))
print("in a circle:", robCircle(street))
print(robCircle([7, 2, 4, 9]), robCircle([4]), robCircle([]))

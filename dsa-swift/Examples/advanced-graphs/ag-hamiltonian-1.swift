// Generated from src/dsa/content/lessons/advanced-graphs/ag-hamiltonian.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Brute force: fix city 0 first, try every order of the rest
func bruteForceTour(_ distance: [[Int]]) -> (length: Int, tours: Int) {
    let n = distance.count
    var best = Int.max
    var tours = 0
    var order: [Int] = []
    var used = [Bool](repeating: false, count: n)
    func extend(_ length: Int) {
        if order.count == n - 1 {
            tours += 1
            best = min(best, length + distance[order.last!][0])   // close the loop
            return
        }
        for city in 1..<n where !used[city] {
            let from = order.last ?? 0
            used[city] = true
            order.append(city)
            extend(length + distance[from][city])
            order.removeLast()
            used[city] = false
        }
    }
    extend(0)
    return (best, tours)
}

let distance = [
    [0, 12, 10, 19, 8],
    [12, 0, 3, 7, 2],
    [10, 3, 0, 6, 20],
    [19, 7, 6, 0, 4],
    [8, 2, 20, 4, 0],
]
let result = bruteForceTour(distance)
print("shortest tour:", result.length, "after trying", result.tours, "tours")
for cities in [5, 10, 13, 16] {
    let tours = (1..<cities).reduce(1, *)        // (cities - 1)! orders of the other cities
    print("\(cities) cities: \(tours) tours")
}

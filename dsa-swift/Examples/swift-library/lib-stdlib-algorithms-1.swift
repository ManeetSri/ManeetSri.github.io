// Generated from src/dsa/content/lessons/swift-library/lib-stdlib-algorithms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let temperatures = [18, 21, 25, 19, 30, 27, 16]

print(temperatures.contains { $0 > 28 })
print(temperatures.allSatisfy { $0 > 10 })
print([Int]().allSatisfy { $0 > 100 })
print(temperatures.first { $0 > 24 } ?? -1)
print(temperatures.firstIndex { $0 > 24 } ?? -1)
print(temperatures.lastIndex { $0 > 24 } ?? -1)
print(temperatures.firstIndex(of: 19) ?? -1)

struct City {
    let name: String
    let population: Int
}

let cities = [
    City(name: "Leeds", population: 812_000),
    City(name: "York", population: 202_000),
    City(name: "Bristol", population: 472_000),
]
print(cities.min { $0.population < $1.population }!.name)
print(cities.max { $0.population < $1.population }!.name)
print(cities.max { $0.population > $1.population }!.name)

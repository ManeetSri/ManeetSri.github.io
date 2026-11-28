// Generated from src/dsa/content/lessons/swift-library/lib-stdlib-algorithms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let laps = [3, 8, 12, 15, 9, 4, 20]
print(laps.prefix(3), laps.suffix(2))
print(laps.dropFirst(5), laps.dropLast(5))
print(laps.prefix { $0 < 14 }, laps.drop { $0 < 14 })
print(laps.prefix(100).count)
let tail = laps.suffix(2)
print(tail.startIndex, tail[5])

var calls = 0
let firstBig = (1...1_000_000).lazy
    .map { number -> Int in
        calls += 1
        return number * number
    }
    .first { $0 > 50 }
print(firstBig ?? -1, calls)

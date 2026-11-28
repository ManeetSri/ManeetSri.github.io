// Generated from src/dsa/content/lessons/bs-on-answer/bsa-bouquets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func bouquets(on day: Int, _ bloomDay: [Int], size k: Int) -> Int {
    var made = 0
    var run = 0                      // adjacent bloomed flowers not yet in a bouquet
    for bloom in bloomDay {
        if bloom <= day {
            run += 1
            if run == k {
                made += 1
                run = 0
            }
        } else {
            run = 0
        }
    }
    return made
}

let bloomDay = [3, 9, 2, 8, 4, 1, 7]
for day in [3, 4, 7, 8, 9] {
    let row = bloomDay.map { $0 <= day ? "x" : "." }.joined()
    print("day \(day): \(row) makes \(bouquets(on: day, bloomDay, size: 2))")
}

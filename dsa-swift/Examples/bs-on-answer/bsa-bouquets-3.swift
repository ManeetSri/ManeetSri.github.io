// Generated from src/dsa/content/lessons/bs-on-answer/bsa-bouquets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func bouquets(on day: Int, _ bloomDay: [Int], size k: Int) -> Int {
    var made = 0
    var run = 0
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

func earliestDay(_ bloomDay: [Int], bouquets m: Int, size k: Int) -> Int {
    guard m <= bloomDay.count / k else { return -1 }     // m × k > n, without multiplying
    var low = bloomDay.min()!
    var high = bloomDay.max()!                           // every flower is out by then
    while low < high {
        let mid = low + (high - low) / 2
        if bouquets(on: mid, bloomDay, size: k) >= m {
            high = mid
        } else {
            low = mid + 1
        }
    }
    return low
}

let bloomDay = [3, 9, 2, 8, 4, 1, 7]
print(earliestDay(bloomDay, bouquets: 2, size: 2))
print(earliestDay(bloomDay, bouquets: 3, size: 2))
print(earliestDay(bloomDay, bouquets: 1, size: 3))
print(earliestDay(bloomDay, bouquets: 4, size: 2))
print(earliestDay(bloomDay, bouquets: 10_000_000_000, size: 10_000_000_000))

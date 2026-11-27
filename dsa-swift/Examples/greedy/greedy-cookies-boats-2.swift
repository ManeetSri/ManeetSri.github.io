// Generated from src/dsa/content/lessons/greedy/greedy-cookies-boats.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func boatsNeeded(_ weights: [Int], limit: Int) -> Int {
    let people = weights.sorted()
    var light = 0
    var heavy = people.count - 1
    var boats = 0
    while light <= heavy {
        if light < heavy && people[light] + people[heavy] <= limit {
            print("boat: \(people[heavy]) and \(people[light])")
            light += 1
        } else {
            print("boat: \(people[heavy]) alone")
        }
        heavy -= 1
        boats += 1
    }
    return boats
}

print(boatsNeeded([3, 5, 3, 4, 2, 1], limit: 5))

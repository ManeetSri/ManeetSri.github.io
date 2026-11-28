// Generated from src/dsa/content/lessons/efficient-sorts/sort-merge.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Player {
    let name: String
    let score: Int
}

func merge(_ left: [Player], _ right: [Player]) -> [Player] {
    var merged: [Player] = []
    var i = 0
    var j = 0
    while i < left.count && j < right.count {
        if left[i].score <= right[j].score {
            merged.append(left[i])
            i += 1
        } else {
            merged.append(right[j])
            j += 1
        }
    }
    merged += left[i...]
    merged += right[j...]
    return merged
}

let morning = [Player(name: "Ana", score: 70), Player(name: "Ben", score: 85)]
let evening = [Player(name: "Cleo", score: 70), Player(name: "Dev", score: 90)]
print(merge(morning, evening).map { "\($0.name) \($0.score)" })

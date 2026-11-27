// Generated from src/dsa/content/lessons/divide-conquer/dc-inversions-majority.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Boyer–Moore's state as a summary that can be merged: what's left after cancelling pairs of different values
struct Votes {
    let candidate: Int
    let votes: Int
}

func merge(_ a: Votes, _ b: Votes) -> Votes {
    if a.candidate == b.candidate {
        return Votes(candidate: a.candidate, votes: a.votes + b.votes)
    }
    // Different candidates: cancel them against each other, pair by pair
    return a.votes >= b.votes ? Votes(candidate: a.candidate, votes: a.votes - b.votes)
                              : Votes(candidate: b.candidate, votes: b.votes - a.votes)
}

func summarise(_ numbers: [Int], _ low: Int, _ high: Int) -> Votes {
    if high - low == 1 {
        return Votes(candidate: numbers[low], votes: 1)
    }
    let mid = low + (high - low) / 2
    return merge(summarise(numbers, low, mid), summarise(numbers, mid, high))
}

for numbers in [[2, 2, 1, 1, 1, 2, 2], [3, 1, 3], [1, 2, 3], [4, 4, 1, 1], [7, 5, 7, 5, 7]] {
    let summary = summarise(numbers, 0, numbers.count)
    let count = numbers.filter { $0 == summary.candidate }.count
    let verdict = count > numbers.count / 2 ? "majority" : "no majority"
    print(numbers, "candidate", summary.candidate, "votes", summary.votes, "→", verdict)
}

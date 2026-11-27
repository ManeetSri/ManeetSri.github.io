// Generated from src/dsa/content/lessons/number-theory/nt-game-theory.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func mex(_ values: [Int]) -> Int {
    var seen = Array(repeating: false, count: values.count + 1)
    for v in values where v < seen.count { seen[v] = true }
    return seen.firstIndex(of: false)!
}

// Lasker's Nim: take any number of stones from one pile, or split one pile into two non-empty piles
var grundy = [0]
for n in 1...16 {
    var options: [Int] = []
    for take in 1...n {
        options.append(grundy[n - take])              // a single smaller pile
    }
    var a = 1
    while a <= n - a {
        options.append(grundy[a] ^ grundy[n - a])     // two piles: a sum of games, so XOR
        a += 1
    }
    grundy.append(mex(options))
}
print(grundy)

// Check the theorem by brute force: search every position of up to three piles of at most 6
var memo: [[Int]: Bool] = [:]
func wins(_ position: [Int]) -> Bool {
    let piles = position.filter { $0 > 0 }.sorted()
    if let known = memo[piles] { return known }
    var result = false
    search: for (i, pile) in piles.enumerated() {
        var rest = piles
        rest.remove(at: i)
        for take in stride(from: 1, through: pile, by: 1) where !wins(rest + [pile - take]) {
            result = true
            break search
        }
        var a = 1
        while a <= pile - a {
            if !wins(rest + [a, pile - a]) {
                result = true
                break search
            }
            a += 1
        }
    }
    memo[piles] = result
    return result
}

var checked = 0
var agree = 0
for x in 0...6 {
    for y in x...6 {
        for z in y...6 {
            checked += 1
            if wins([x, y, z]) == (grundy[x] ^ grundy[y] ^ grundy[z] != 0) { agree += 1 }
        }
    }
}
print(checked, agree)

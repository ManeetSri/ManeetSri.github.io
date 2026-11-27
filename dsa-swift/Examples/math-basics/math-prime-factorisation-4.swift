// Generated from src/dsa/content/lessons/math-basics/math-prime-factorisation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let limit = 100
var spf = Array(0...limit)
var p = 2
while p * p <= limit {
    if spf[p] == p {
        for m in stride(from: p * p, through: limit, by: p) where spf[m] == m {
            spf[m] = p
        }
    }
    p += 1
}

func factor(_ number: Int) -> [Int] {
    var n = number
    var result: [Int] = []
    while n > 1 {
        result.append(spf[n])
        n /= spf[n]
    }
    return result
}

print(spf[91], spf[97])
print(factor(84), factor(97), factor(64))

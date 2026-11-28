// Generated from src/dsa/content/lessons/number-theory/nt-fft.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func naiveMultiply(_ a: [Int], _ b: [Int]) -> [Int] {
    var c = Array(repeating: 0, count: a.count + b.count - 1)
    for i in a.indices {
        for j in b.indices {
            c[i + j] += a[i] * b[j]
        }
    }
    return c
}

// One die: one way to roll each of 1…6, so the coefficient of xˢ counts the ways to make s
let die = [0, 1, 1, 1, 1, 1, 1]
let twoDice = naiveMultiply(die, die)
print(twoDice)
print(twoDice.firstIndex(of: twoDice.max()!)!, twoDice.reduce(0, +))
let threeDice = naiveMultiply(twoDice, die)
print(threeDice[10], threeDice.reduce(0, +))

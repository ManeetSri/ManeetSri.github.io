// Generated from src/dsa/content/lessons/math-basics/math-number-systems.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let symbols = Array("0123456789abcdef")

func toBase(_ number: Int, _ base: Int) -> String {
    var n = number
    var digits: [Character] = []
    repeat {
        digits.append(symbols[n % base])
        n /= base
    } while n > 0
    return String(digits.reversed())
}

print(toBase(45, 2))
print(toBase(45, 16))
print(toBase(0, 2))

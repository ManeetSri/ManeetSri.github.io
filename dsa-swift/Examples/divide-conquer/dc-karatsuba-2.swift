// Generated from src/dsa/content/lessons/divide-conquer/dc-karatsuba.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Big numbers as arrays of decimal digits, least significant first: 1234 is [4, 3, 2, 1]
var digitProducts = 0                                    // single-digit multiplications performed

func digits(_ text: String) -> [Int] {
    text.reversed().map { Int(String($0))! }
}

func text(_ digits: [Int]) -> String {
    digits.reversed().map(String.init).joined()
}

func trimmed(_ number: [Int]) -> [Int] {                 // drop leading zeros, keeping at least one digit
    var number = number
    while number.count > 1 && number.last == 0 {
        number.removeLast()
    }
    return number
}

func add(_ a: [Int], _ b: [Int]) -> [Int] {
    var result: [Int] = []
    var carry = 0
    for i in 0..<max(a.count, b.count) {
        let sum = (i < a.count ? a[i] : 0) + (i < b.count ? b[i] : 0) + carry
        result.append(sum % 10)
        carry = sum / 10
    }
    if carry > 0 {
        result.append(carry)
    }
    return result
}

func subtract(_ a: [Int], _ b: [Int]) -> [Int] {        // a - b, where a ≥ b
    var result: [Int] = []
    var borrow = 0
    for i in 0..<a.count {
        var difference = a[i] - borrow - (i < b.count ? b[i] : 0)
        borrow = difference < 0 ? 1 : 0
        if difference < 0 {
            difference += 10
        }
        result.append(difference)
    }
    return trimmed(result)
}

func shifted(_ a: [Int], by places: Int) -> [Int] {     // multiply by 10^places
    a == [0] ? a : Array(repeating: 0, count: places) + a
}

func schoolbook(_ a: [Int], _ b: [Int]) -> [Int] {
    var result = Array(repeating: 0, count: a.count + b.count)
    for i in a.indices {
        var carry = 0
        for j in b.indices {
            digitProducts += 1
            let current = result[i + j] + a[i] * b[j] + carry
            result[i + j] = current % 10
            carry = current / 10
        }
        result[i + b.count] += carry
    }
    return trimmed(result)
}

func karatsuba(_ a: [Int], _ b: [Int], cutoff: Int) -> [Int] {
    if a.count <= cutoff || b.count <= cutoff {
        return schoolbook(a, b)                          // small enough: the plain method is faster
    }
    let m = max(a.count, b.count) / 2                    // split off the m lowest digits
    let a0 = trimmed(Array(a.prefix(m))), a1 = a.count > m ? Array(a.dropFirst(m)) : [0]
    let b0 = trimmed(Array(b.prefix(m))), b1 = b.count > m ? Array(b.dropFirst(m)) : [0]
    let high = karatsuba(a1, b1, cutoff: cutoff)
    let low = karatsuba(a0, b0, cutoff: cutoff)
    let both = karatsuba(add(a1, a0), add(b1, b0), cutoff: cutoff)
    let middle = subtract(subtract(both, high), low)
    return trimmed(add(add(shifted(high, by: 2 * m), shifted(middle, by: m)), low))
}

let x = digits("12345678901234567890")
let y = digits("98765432109876543210")
print(text(karatsuba(x, y, cutoff: 4)))

// Count digit products on random numbers, recursing all the way down to single digits
var seed: UInt64 = 1_960
func randomDigits(_ count: Int) -> [Int] {
    var result: [Int] = []
    for _ in 0..<count {
        seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        result.append(Int((seed >> 33) % 10))
    }
    result[count - 1] = max(result[count - 1], 1)        // no leading zero
    return result
}

for n in [64, 256, 1_024] {
    let a = randomDigits(n), b = randomDigits(n)
    digitProducts = 0
    let plain = schoolbook(a, b)
    let plainCount = digitProducts
    digitProducts = 0
    let fast = karatsuba(a, b, cutoff: 1)
    print("\(n) digits: \(plain == fast ? "same product" : "different!"), schoolbook \(plainCount), Karatsuba \(digitProducts) digit products")
}

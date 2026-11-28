// Generated from src/dsa/content/lessons/greedy/greedy-cookies-boats.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Can the stall give everyone change? Each pie costs 5; the till starts empty.
// `tenFirst` chooses how to change a 20: a ten and a five if possible, or always three fives.
func canChange(_ payments: [Int], tenFirst: Bool) -> Bool {
    var fives = 0
    var tens = 0
    for (customer, note) in payments.enumerated() {
        switch note {
        case 5:
            fives += 1
        case 10:
            guard fives >= 1 else { print("  customer \(customer + 1): no five for a 10"); return false }
            fives -= 1
            tens += 1
        default:                                    // a 20 needs 15 back
            if tenFirst && tens >= 1 && fives >= 1 {
                tens -= 1
                fives -= 1
            } else if fives >= 3 {
                fives -= 3
            } else if tens >= 1 && fives >= 1 {
                tens -= 1
                fives -= 1
            } else {
                print("  customer \(customer + 1): can't change a 20")
                return false
            }
        }
    }
    return true
}

let queue = [5, 5, 5, 5, 10, 20, 10, 10]
print("ten and five first:", canChange(queue, tenFirst: true))
print("three fives first:", canChange(queue, tenFirst: false))
print("ten and five first:", canChange([5, 10, 5, 20, 20], tenFirst: true))

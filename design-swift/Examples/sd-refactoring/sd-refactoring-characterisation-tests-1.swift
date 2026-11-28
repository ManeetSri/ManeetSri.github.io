// Generated from src/dsa/design/content/lessons/sd-refactoring/sd-refactoring-characterisation-tests.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// The legacy rule, untouched: it's the oracle
func legacyPoints(total: Int, tier: String, firstOrder: Bool) -> Int {
    var points = total / 100
    if tier == "gold" {
        points = points * 2
    } else if tier == "silver" {
        points = points + points / 2
    }
    if firstOrder && total > 2000 {
        points += 50
    }
    if points > 500 {
        points = 500
    }
    return points
}

// Two refactored candidates. One of them changed behaviour.
func refactoredPoints(total: Int, tier: String, firstOrder: Bool) -> Int {
    let base = total / 100
    let earned = base + tierBonus(base, tier)
    let bonus = firstOrder && total > 2000 ? 50 : 0
    return min(earned + bonus, 500)
}

func hastyPoints(total: Int, tier: String, firstOrder: Bool) -> Int {
    let base = total / 100
    let earned = min(base + tierBonus(base, tier), 500)
    return earned + (firstOrder && total > 2000 ? 50 : 0)
}

func tierBonus(_ base: Int, _ tier: String) -> Int {
    switch tier {
    case "gold": base
    case "silver": base / 2
    default: 0
    }
}

// The golden master: every combination of values either side of each condition
func differences(_ candidate: (Int, String, Bool) -> Int) -> [String] {
    var found: [String] = []
    for total in [0, 99, 100, 1999, 2000, 2001, 24900, 25000, 26000] {
        for tier in ["bronze", "silver", "gold", "Gold", ""] {
            for firstOrder in [false, true] {
                let expected = legacyPoints(total: total, tier: tier, firstOrder: firstOrder)
                let actual = candidate(total, tier, firstOrder)
                if actual != expected {
                    found.append("total \(total), tier \(tier), first order \(firstOrder): legacy \(expected), new \(actual)")
                }
            }
        }
    }
    return found
}

for (name, candidate) in [("refactoredPoints", refactoredPoints), ("hastyPoints", hastyPoints)] {
    let found = differences(candidate)
    print("\(name): \(found.count) differences in 90 orders")
    if let first = found.first {
        print("  first: \(first)")
    }
}

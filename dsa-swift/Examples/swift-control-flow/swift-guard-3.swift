// Generated from src/dsa/content/lessons/swift-control-flow/swift-guard.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func triangleKind(a: Int, b: Int, c: Int) -> String {
    guard a > 0 && b > 0 && c > 0 else {
        return "Sides must be positive"
    }
    guard a + b > c && a + c > b && b + c > a else {
        return "Not a triangle"
    }

    if a == b && b == c {
        return "Equilateral"
    } else if a == b || b == c || a == c {
        return "Isosceles"
    } else {
        return "Scalene"
    }
}

print(triangleKind(a: 3, b: 3, c: 3))
print(triangleKind(a: 3, b: 4, c: 5))
print(triangleKind(a: 1, b: 2, c: 8))
print(triangleKind(a: 0, b: 2, c: 2))

// Reference solution: What kind of triangle? A guard rules out impossible sides, then each
// check returns as soon as it knows the answer. O(1) time and space.

public enum TriangleKind {
    public static func kind(a: Int, b: Int, c: Int) -> String {
        guard a > 0, b > 0, c > 0, a + b > c, a + c > b, b + c > a else {
            return "invalid"
        }
        if a == b && b == c {
            return "equilateral"
        }
        if a == b || b == c || a == c {
            return "isosceles"
        }
        return "scalene"
    }
}

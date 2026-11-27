// Reference solution: A profile line. One interpolated string, with the maths done inside it.
// O(n) time and space, where n is the length of the result.

public enum ProfileLine {
    public static func describe(name: String, age: Int, city: String) -> String {
        "\(name) is \(age) and lives in \(city). Next year: \(age + 1)."
    }
}

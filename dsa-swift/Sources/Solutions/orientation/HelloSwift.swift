// Reference solution: Hello, Swift

public enum HelloSwift {
    public static func greet(_ name: String) -> String {
        guard !name.isEmpty else { return "Hello, world!" }
        return "Hello, \(name)!"
    }
}

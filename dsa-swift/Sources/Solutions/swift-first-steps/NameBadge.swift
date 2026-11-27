// Reference solution: A boxed name badge. Build the border once as a constant (two more dashes
// than the name has characters, for the spaces either side), then interpolate it twice.
// O(n) time and space for a name of n characters.

public enum NameBadge {
    public static func badge(for name: String) -> String {
        let border = "+" + String(repeating: "-", count: name.count + 2) + "+"
        return "\(border)\n| \(name) |\n\(border)"
    }
}

// Reference solution: Username rules. One Bool expression, one rule per line, joined with &&,
// which stops at the first rule that fails. O(n) time and space for a username of n characters.

public enum UsernameRules {
    public static func isValid(_ username: String) -> Bool {
        !username.isEmpty
            && username.count <= 15
            && !username.contains(" ")
            && !username.hasPrefix("_")
            && username.lowercased() != "admin"
    }
}

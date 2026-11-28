// Problem: Fewest edits between words (M54 · Edit distance)

public enum WordEditScript {
    /// One step of an edit script, read from left to right across the source.
    public enum Step: Equatable {
        case keep(Character)                        // copy the next source character unchanged
        case replace(Character, with: Character)    // turn the next source character into a different one
        case delete(Character)                      // drop the next source character
        case insert(Character)                      // write a new character
    }

    /// The fewest single-character insertions, deletions and replacements that turn `source` into `target`.
    public static func distance(from source: String, to target: String) -> Int {
        // Write your solution here, then run:
        // swift test --filter WordEditScriptTests
        return 0
    }

    /// A script that turns `source` into `target` using exactly `distance(from:to:)` edits. Any
    /// shortest script is accepted.
    public static func script(from source: String, to target: String) -> [Step] {
        return []
    }
}

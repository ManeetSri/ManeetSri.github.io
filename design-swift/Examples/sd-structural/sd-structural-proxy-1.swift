// Generated from src/dsa/design/content/lessons/sd-structural/sd-structural-proxy.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

protocol SpellChecking {
    func isCorrect(_ word: String) -> Bool
}

// The real subject: expensive to create
final class WordListChecker: SpellChecking {
    private let words: Set<String>

    init() {
        print("Loading 300,000 words…")
        words = ["colour", "favourite", "organise", "proxy"]
    }

    func isCorrect(_ word: String) -> Bool {
        words.contains(word.lowercased())
    }
}

// The virtual proxy: same interface, creates the subject on first use
final class LazySpellChecker: SpellChecking {
    private lazy var real = WordListChecker()

    func isCorrect(_ word: String) -> Bool {
        real.isCorrect(word)
    }
}

let checker: any SpellChecking = LazySpellChecker()
print("Editor opened")
print(checker.isCorrect("Colour"))
print(checker.isCorrect("color"))

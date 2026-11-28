import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct FileExtensionTallyTests {
    @Test("Counts extensions")
    func counts() {
        let names = ["photo.jpg", "notes.txt", "report.final.txt", "song.mp3", "beach.jpg"]
        #expect(FileExtensionTally.tally(names) == ["jpg": 2, "txt": 2, "mp3": 1])
    }

    @Test("Only the last dot matters")
    func lastDot() {
        let names = ["archive.tar.gz", ".config.json", "a.b.c.d", "..txt"]
        #expect(FileExtensionTally.tally(names) == ["gz": 1, "json": 1, "d": 1, "txt": 1])
    }

    @Test("Names without an extension aren't counted", arguments: [
        "README", ".gitignore", "notes.", ".", "..", "Makefile", "",
    ])
    func noExtension(name: String) {
        #expect(FileExtensionTally.tally([name]) == [:])
    }

    @Test("Extensions are compared exactly as written")
    func caseSensitive() {
        #expect(FileExtensionTally.tally(["a.JSON", "b.json", "c.Json", "d.json"]) == ["JSON": 1, "json": 2, "Json": 1])
    }

    @Test("Mixes counted and skipped names")
    func mixed() {
        let names = ["README", "main.swift", ".gitignore", "Package.swift", "notes.", "logo.png"]
        #expect(FileExtensionTally.tally(names) == ["swift": 2, "png": 1])
    }

    @Test("Extensions can be long or contain any characters")
    func unusualExtensions() {
        #expect(FileExtensionTally.tally(["data.backup-2024", "caf\u{E9}.cr\u{E8}me", "x.1"]) == ["backup-2024": 1, "cr\u{E8}me": 1, "1": 1])
    }

    @Test("No names means no counts")
    func empty() {
        #expect(FileExtensionTally.tally([]) == [:])
    }

    @Test("Handles 10,000 names")
    func large() {
        let extensions = ["swift", "md", "json", "png"]
        let names = (0..<10_000).map { "file\($0)." + extensions[$0 % 4] }
        #expect(FileExtensionTally.tally(names) == ["swift": 2_500, "md": 2_500, "json": 2_500, "png": 2_500])
    }
}

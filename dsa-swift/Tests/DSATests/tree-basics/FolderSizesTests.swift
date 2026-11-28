import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Folder = FolderSizes.Folder

@Suite struct FolderSizesTests {
    // Home (10)
    // ├── Documents (200)
    // │   ├── Taxes (1,000)
    // │   └── Letters (50)
    // ├── Photos (5,000)
    // │   └── 2026 (2,500)
    // └── Music (0)
    static func home() -> FolderSizes.Folder {
        Folder("Home", fileBytes: 10, subfolders: [
            Folder("Documents", fileBytes: 200, subfolders: [
                Folder("Taxes", fileBytes: 1_000),
                Folder("Letters", fileBytes: 50),
            ]),
            Folder("Photos", fileBytes: 5_000, subfolders: [
                Folder("2026", fileBytes: 2_500),
            ]),
            Folder("Music"),
        ])
    }

    @Test("Totals and levels of the example")
    func example() {
        let home = Self.home()
        #expect(FolderSizes.totalBytes(home) == 8_760)
        #expect(FolderSizes.totalBytes(home.subfolders[0]) == 1_250)
        #expect(FolderSizes.totalBytes(home.subfolders[1]) == 7_500)
        #expect(FolderSizes.totalBytes(home.subfolders[2]) == 0)
        #expect(FolderSizes.levels(home) == 3)
        #expect(FolderSizes.levels(home.subfolders[1]) == 2)
        #expect(FolderSizes.levels(home.subfolders[2]) == 1)
    }

    @Test("Big folders, in preorder", arguments: [
        (1_000, ["Home", "Home/Documents", "Home/Documents/Taxes", "Home/Photos", "Home/Photos/2026"]),
        (5_000, ["Home", "Home/Photos"]),
        (8_760, ["Home"]),
        (8_761, []),
        (0, ["Home", "Home/Documents", "Home/Documents/Taxes", "Home/Documents/Letters", "Home/Photos", "Home/Photos/2026", "Home/Music"]),
        (51, ["Home", "Home/Documents", "Home/Documents/Taxes", "Home/Photos", "Home/Photos/2026"]),
        (50, ["Home", "Home/Documents", "Home/Documents/Taxes", "Home/Documents/Letters", "Home/Photos", "Home/Photos/2026"]),
    ])
    func bigFolders(threshold: Int, expected: [String]) {
        #expect(FolderSizes.folders(atLeast: threshold, in: Self.home()) == expected)
    }

    @Test("A folder on its own")
    func single() {
        let empty = Folder("Empty")
        #expect(FolderSizes.totalBytes(empty) == 0)
        #expect(FolderSizes.levels(empty) == 1)
        #expect(FolderSizes.folders(atLeast: 0, in: empty) == ["Empty"])
        #expect(FolderSizes.folders(atLeast: 1, in: empty) == [])
        let notes = Folder("Notes", fileBytes: 7)
        #expect(FolderSizes.totalBytes(notes) == 7)
        #expect(FolderSizes.folders(atLeast: 7, in: notes) == ["Notes"])
    }

    @Test("Subfolders keep their order, even when a later one is bigger")
    func order() {
        let root = Folder("R", subfolders: [
            Folder("small", fileBytes: 5, subfolders: [Folder("deep", fileBytes: 5)]),
            Folder("big", fileBytes: 100),
        ])
        #expect(FolderSizes.folders(atLeast: 5, in: root) == ["R", "R/small", "R/small/deep", "R/big"])
    }

    @Test("100,001 folders: a root with 1,000 subfolders of 99 each")
    func wide() {
        let root = Folder("Root", subfolders: (0..<1_000).map { i in
            Folder("f\(i)", fileBytes: 10, subfolders: (0..<99).map { j in Folder("g\(j)", fileBytes: 1) })
        })
        #expect(FolderSizes.totalBytes(root) == 109_000)
        #expect(FolderSizes.levels(root) == 3)
        let big = FolderSizes.folders(atLeast: 109, in: root)
        #expect(big.count == 1_001)
        #expect(big.first == "Root")
        #expect(big.last == "Root/f999")
        let all = FolderSizes.folders(atLeast: 1, in: root)
        #expect(all.count == 100_001)
        #expect(all.prefix(3) == ["Root", "Root/f0", "Root/f0/g0"])
        #expect(all.last == "Root/f999/g98")
    }

    @Test("A chain of 300 folders")
    func deep() {
        let root = Folder("d", fileBytes: 1)
        var current = root
        for _ in 1..<300 {
            let next = Folder("d", fileBytes: 1)
            current.subfolders = [next]
            current = next
        }
        #expect(FolderSizes.totalBytes(root) == 300)
        #expect(FolderSizes.levels(root) == 300)
        let big = FolderSizes.folders(atLeast: 150, in: root)
        #expect(big.count == 151)
        #expect(big.last == "d" + String(repeating: "/d", count: 150))
    }
}

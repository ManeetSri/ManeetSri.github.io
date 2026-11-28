import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MenuTreeCompositeTests {
    typealias Element = MenuTreeComposite.Element

    private static func action(_ id: String, _ title: String) -> Element {
        .action(MenuTreeComposite.Action(id: id, title: title))
    }

    /// A photo's context menu, three levels deep
    private let photoMenu: Element = .menu(title: "Photo", children: [
        action("favourite", "Favourite"),
        .menu(title: "Share", children: [
            action("copy-link", "Copy Link"),
            action("message", "Message"),
            .menu(title: "More", children: [action("airdrop", "AirDrop")]),
        ]),
        .menu(title: "Edit", children: [action("crop", "Crop"), action("filters", "Filters")]),
        action("delete", "Delete"),
    ])

    @Test("Counts the actions at every depth")
    func countsActions() {
        #expect(photoMenu.actionCount == 7)
        #expect(Self.action("delete", "Delete").actionCount == 1)
        #expect(Element.menu(title: "Empty", children: []).actionCount == 0)
    }

    @Test("Filtering keeps what's left in its place")
    func filtersActions() {
        let withoutMessaging = photoMenu.filtered { !["message", "airdrop"].contains($0.id) }
        #expect(withoutMessaging == .menu(title: "Photo", children: [
            Self.action("favourite", "Favourite"),
            .menu(title: "Share", children: [Self.action("copy-link", "Copy Link")]),
            .menu(title: "Edit", children: [Self.action("crop", "Crop"), Self.action("filters", "Filters")]),
            Self.action("delete", "Delete"),
        ]))
    }

    @Test("Submenus left with no actions disappear, at any depth")
    func prunesEmptySubmenus() {
        let readOnly = photoMenu.filtered { ["favourite", "copy-link"].contains($0.id) }
        #expect(readOnly == .menu(title: "Photo", children: [
            Self.action("favourite", "Favourite"),
            .menu(title: "Share", children: [Self.action("copy-link", "Copy Link")]),
        ]))
        let nested: Element = .menu(title: "A", children: [.menu(title: "B", children: [.menu(title: "C", children: [])]), Self.action("x", "X")])
        #expect(nested.filtered { _ in true } == .menu(title: "A", children: [Self.action("x", "X")]))
    }

    @Test("Keeping everything changes nothing; keeping nothing leaves nil")
    func filterExtremes() {
        #expect(photoMenu.filtered { _ in true } == photoMenu)
        #expect(Self.action("crop", "Crop").filtered { _ in true } == Self.action("crop", "Crop"))
        #expect(photoMenu.filtered { _ in false } == nil)
        #expect(Element.menu(title: "Empty", children: []).filtered { _ in true } == nil)
    }

    @Test("Finds the titles on the way to an action")
    func findsPaths() {
        #expect(photoMenu.titlePath(to: "airdrop") == ["Photo", "Share", "More", "AirDrop"])
        #expect(photoMenu.titlePath(to: "delete") == ["Photo", "Delete"])
        #expect(Self.action("crop", "Crop").titlePath(to: "crop") == ["Crop"])
        #expect(photoMenu.titlePath(to: "print") == nil)
    }

    @Test("Reports action ids used more than once")
    func findsDuplicates() {
        #expect(photoMenu.duplicateActionIDs.isEmpty)
        let clashing: Element = .menu(title: "Photo", children: [
            Self.action("share", "Share"),
            .menu(title: "Edit", children: [Self.action("crop", "Crop"), Self.action("share", "Share Edit")]),
            .menu(title: "More", children: [Self.action("crop", "Crop Again"), .menu(title: "Even more", children: [Self.action("share", "Share")])]),
            Self.action("delete", "Delete"),
        ])
        #expect(clashing.duplicateActionIDs == ["crop", "share"])
    }
}

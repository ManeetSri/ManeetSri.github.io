// Generated from src/dsa/content/lessons/swift-memory/swift-weak-unowned.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Book {
    let title: String
    var pages: [Page] = []

    init(title: String) { self.title = title }
    deinit { print("\(title) freed") }

    func addPage(number: Int) {
        pages.append(Page(number: number, book: self))
    }
}

final class Page {
    let number: Int
    unowned let book: Book

    init(number: Int, book: Book) {
        self.number = number
        self.book = book
    }
    deinit { print("page \(number) freed") }
}

do {
    let book = Book(title: "Swift Notes")
    book.addPage(number: 1)
    book.addPage(number: 2)
    print("page 2 belongs to \(book.pages[1].book.title)")
}
print("done")

// Kata: A paginated catalogue view model (D27 · Modelling view state; Testing view models)
import Foundation
import Observation

public enum PagedCatalogScreen {
    public struct Product: Equatable, Sendable, Identifiable {
        public let id: Int
        public let name: String

        public init(id: Int, name: String) {
            self.id = id
            self.name = name
        }
    }

    public struct Page: Equatable, Sendable {
        public let products: [Product]
        /// Where the next page starts, or nil on the last page
        public let nextCursor: String?

        public init(products: [Product], nextCursor: String?) {
            self.products = products
            self.nextCursor = nextCursor
        }
    }

    public protocol CatalogLoading: Sendable {
        /// The first page when `cursor` is nil, otherwise the page that `cursor` points to
        func page(after cursor: String?) async throws -> Page
    }

    /// The row at the bottom of a loaded list
    public enum Footer: Equatable, Sendable {
        /// Another page exists; the list asks for it when the last row appears
        case more
        case loadingMore
        /// The next page failed; the footer offers a retry and the rows above stay
        case failed(message: String)
        /// The last page has loaded
        case end
    }

    public struct Loaded: Equatable, Sendable {
        public var products: [Product]
        public var footer: Footer
        /// A pull to refresh is running; the rows stay on screen
        public var isRefreshing: Bool
        /// The last refresh failed; shown above the rows, which stay
        public var banner: String?

        public init(products: [Product], footer: Footer, isRefreshing: Bool = false, banner: String? = nil) {
            self.products = products
            self.footer = footer
            self.isRefreshing = isRefreshing
            self.banner = banner
        }
    }

    public enum ViewState: Equatable, Sendable {
        case idle
        case loading
        case empty
        case failed(message: String)
        case loaded(Loaded)
    }

    public static let offlineMessage = "You're offline."
    public static let failureMessage = "Couldn't load products."

    @MainActor
    @Observable
    public final class ViewModel {
        public private(set) var state: ViewState = .idle

        public init(catalog: any CatalogLoading) {}

        /// The first load, and Retry on the failed screen
        public func load() async {
            // Write your solution here, then run:
            // swift test --filter PagedCatalogScreenTests
        }

        /// The last row appeared, or the user tapped Retry in a failed footer
        public func loadMore() async {}

        /// Pull to refresh
        public func refresh() async {}
    }
}

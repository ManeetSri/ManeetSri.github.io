// Reference solution: A paginated catalogue view model. The view state says what's on screen; the cursor
// and a generation number are the view model's own bookkeeping. Every request remembers the generation it
// started in, and a refresh starts a new one, so a page meant for the old list is dropped when it arrives.
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
        public let nextCursor: String?

        public init(products: [Product], nextCursor: String?) {
            self.products = products
            self.nextCursor = nextCursor
        }
    }

    public protocol CatalogLoading: Sendable {
        func page(after cursor: String?) async throws -> Page
    }

    public enum Footer: Equatable, Sendable {
        case more
        case loadingMore
        case failed(message: String)
        case end
    }

    public struct Loaded: Equatable, Sendable {
        public var products: [Product]
        public var footer: Footer
        public var isRefreshing: Bool
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

        private let catalog: any CatalogLoading
        /// Where the next page starts. Bookkeeping, not view state: the view never shows it.
        private var nextCursor: String?
        /// Bumped by every first load and refresh; answers from an older generation are stale
        private var generation = 0

        public init(catalog: any CatalogLoading) {
            self.catalog = catalog
        }

        public func load() async {
            switch state {
            case .idle, .failed: await loadFirstPage()
            case .loading, .empty, .loaded: return
            }
        }

        public func loadMore() async {
            guard case .loaded(var loaded) = state, !loaded.isRefreshing, let cursor = nextCursor else { return }
            switch loaded.footer {
            case .more, .failed: break
            case .loadingMore, .end: return
            }
            loaded.footer = .loadingMore
            state = .loaded(loaded)
            let started = generation

            do {
                let page = try await catalog.page(after: cursor)
                guard started == generation, case .loaded(var latest) = state else { return }
                var seen = Set(latest.products.map(\.id))
                for product in page.products where seen.insert(product.id).inserted {
                    latest.products.append(product)
                }
                nextCursor = page.nextCursor
                latest.footer = page.nextCursor == nil ? .end : .more
                state = .loaded(latest)
            } catch {
                guard started == generation, case .loaded(var latest) = state else { return }
                latest.footer = PagedCatalogScreen.message(for: error).map { .failed(message: $0) } ?? .more
                state = .loaded(latest)
            }
        }

        public func refresh() async {
            switch state {
            case .loaded(var loaded):
                guard !loaded.isRefreshing else { return }
                loaded.isRefreshing = true
                loaded.banner = nil
                // A load-more in flight belongs to the list being replaced: abandon it
                if loaded.footer == .loadingMore { loaded.footer = .more }
                state = .loaded(loaded)
                generation += 1
                let started = generation

                do {
                    let page = try await catalog.page(after: nil)
                    guard started == generation else { return }
                    show(firstPage: page)
                } catch {
                    guard started == generation, case .loaded(var latest) = state else { return }
                    latest.isRefreshing = false
                    latest.banner = PagedCatalogScreen.message(for: error)
                    state = .loaded(latest)
                }
            case .empty, .failed:
                await loadFirstPage()
            case .idle, .loading:
                return
            }
        }

        private func loadFirstPage() async {
            state = .loading
            generation += 1
            let started = generation
            do {
                let page = try await catalog.page(after: nil)
                guard started == generation else { return }
                show(firstPage: page)
            } catch {
                guard started == generation else { return }
                state = PagedCatalogScreen.message(for: error).map { .failed(message: $0) } ?? .idle
            }
        }

        private func show(firstPage page: Page) {
            var seen = Set<Int>()
            let products = page.products.filter { seen.insert($0.id).inserted }
            nextCursor = page.nextCursor
            state = products.isEmpty ? .empty : .loaded(Loaded(products: products, footer: page.nextCursor == nil ? .end : .more))
        }
    }

    /// What to show for a failure, or nil when the request was cancelled rather than failed
    static func message(for error: any Error) -> String? {
        if error is CancellationError { return nil }
        guard let error = error as? URLError else { return failureMessage }
        switch error.code {
        case .cancelled: return nil
        case .notConnectedToInternet: return offlineMessage
        default: return failureMessage
        }
    }
}

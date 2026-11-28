// Kata: Upload strategies (D12 · Strategy: swappable algorithms)
import Foundation

public enum UploadResizePolicy {
    /// What the app knows about the current network, as `NWPath` reports it
    public struct Network: Equatable, Sendable {
        /// Cellular or a personal hotspot (`NWPath.isExpensive`)
        public var isExpensive: Bool
        /// Low Data Mode is on (`NWPath.isConstrained`)
        public var isConstrained: Bool

        public init(isExpensive: Bool = false, isConstrained: Bool = false) {
            self.isExpensive = isExpensive
            self.isConstrained = isConstrained
        }
    }

    /// A photo's size in pixels
    public struct Photo: Equatable, Sendable {
        public var width: Int
        public var height: Int

        public init(width: Int, height: Int) {
            self.width = width
            self.height = height
        }
    }

    /// How to encode one photo for upload: its size in pixels and a JPEG quality from 0 to 1
    public struct Plan: Equatable, Sendable {
        public var width: Int
        public var height: Int
        public var quality: Double

        public init(width: Int, height: Int, quality: Double) {
            self.width = width
            self.height = height
            self.quality = quality
        }
    }

    /// One way of deciding how to upload a photo
    public protocol Strategy: Sendable {
        func plan(for photo: Photo, on network: Network) -> Plan
    }

    /// Uploads the photo at its own size, at quality 1
    public struct Original: Strategy {
        public init() {}

        public func plan(for photo: Photo, on network: Network) -> Plan {
            // Write your solution here, then run:
            // swift test --filter UploadResizePolicyTests
            Plan(width: 0, height: 0, quality: 0)
        }
    }

    /// Scales the photo down, keeping its shape, so its longer side is at most `maxSide` pixels. It never
    /// scales up. Each side is rounded to the nearest pixel (halves round up) and is at least 1.
    public struct FitWithin: Strategy {
        public let maxSide: Int
        public let quality: Double

        public init(maxSide: Int, quality: Double) {
            self.maxSide = maxSide
            self.quality = quality
        }

        public func plan(for photo: Photo, on network: Network) -> Plan {
            Plan(width: 0, height: 0, quality: 0)
        }
    }

    /// Chooses another strategy by network: `lowData` in Low Data Mode, otherwise `cellular` on an
    /// expensive network, otherwise `unmetered`
    public struct ByNetwork: Strategy {
        public init(unmetered: any Strategy, cellular: any Strategy, lowData: any Strategy) {}

        public func plan(for photo: Photo, on network: Network) -> Plan {
            Plan(width: 0, height: 0, quality: 0)
        }
    }

    /// A strategy written as a closure, for one-off rules and tests
    public struct Custom: Strategy {
        public init(_ plan: @escaping @Sendable (Photo, Network) -> Plan) {}

        public func plan(for photo: Photo, on network: Network) -> Plan {
            Plan(width: 0, height: 0, quality: 0)
        }
    }

    /// The context: photos waiting to upload, planned by whichever strategy it has right now
    public struct UploadQueue: Sendable {
        public var strategy: any Strategy
        public private(set) var photos: [Photo] = []

        public init(strategy: any Strategy) {
            self.strategy = strategy
        }

        public mutating func add(_ photo: Photo) {}

        /// A plan for each waiting photo, in the order they were added
        public func plans(on network: Network) -> [Plan] {
            []
        }
    }
}

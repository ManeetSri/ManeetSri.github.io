// Reference solution: Upload strategies. Every strategy answers the same question, so the queue never
// asks which one it has. ByNetwork is itself a strategy that delegates to others, so rules compose
// without the queue knowing; Custom turns a closure into a strategy for one-offs and tests.
import Foundation

public enum UploadResizePolicy {
    public struct Network: Equatable, Sendable {
        public var isExpensive: Bool
        public var isConstrained: Bool

        public init(isExpensive: Bool = false, isConstrained: Bool = false) {
            self.isExpensive = isExpensive
            self.isConstrained = isConstrained
        }
    }

    public struct Photo: Equatable, Sendable {
        public var width: Int
        public var height: Int

        public init(width: Int, height: Int) {
            self.width = width
            self.height = height
        }
    }

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

    public protocol Strategy: Sendable {
        func plan(for photo: Photo, on network: Network) -> Plan
    }

    public struct Original: Strategy {
        public init() {}

        public func plan(for photo: Photo, on network: Network) -> Plan {
            Plan(width: photo.width, height: photo.height, quality: 1)
        }
    }

    public struct FitWithin: Strategy {
        public let maxSide: Int
        public let quality: Double

        public init(maxSide: Int, quality: Double) {
            self.maxSide = maxSide
            self.quality = quality
        }

        public func plan(for photo: Photo, on network: Network) -> Plan {
            let longer = max(photo.width, photo.height)
            let scale = min(1, Double(maxSide) / Double(longer))
            func scaled(_ side: Int) -> Int {
                max(1, Int((Double(side) * scale).rounded()))
            }
            return Plan(width: scaled(photo.width), height: scaled(photo.height), quality: quality)
        }
    }

    public struct ByNetwork: Strategy {
        private let unmetered: any Strategy
        private let cellular: any Strategy
        private let lowData: any Strategy

        public init(unmetered: any Strategy, cellular: any Strategy, lowData: any Strategy) {
            self.unmetered = unmetered
            self.cellular = cellular
            self.lowData = lowData
        }

        public func plan(for photo: Photo, on network: Network) -> Plan {
            let chosen = network.isConstrained ? lowData : network.isExpensive ? cellular : unmetered
            return chosen.plan(for: photo, on: network)
        }
    }

    public struct Custom: Strategy {
        private let makePlan: @Sendable (Photo, Network) -> Plan

        public init(_ plan: @escaping @Sendable (Photo, Network) -> Plan) {
            makePlan = plan
        }

        public func plan(for photo: Photo, on network: Network) -> Plan {
            makePlan(photo, network)
        }
    }

    public struct UploadQueue: Sendable {
        public var strategy: any Strategy
        public private(set) var photos: [Photo] = []

        public init(strategy: any Strategy) {
            self.strategy = strategy
        }

        public mutating func add(_ photo: Photo) {
            photos.append(photo)
        }

        public func plans(on network: Network) -> [Plan] {
            photos.map { strategy.plan(for: $0, on: network) }
        }
    }
}

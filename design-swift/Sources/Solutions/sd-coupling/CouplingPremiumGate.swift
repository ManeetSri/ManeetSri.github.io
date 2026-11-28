// Reference solution: Premium gate. The gate owns `EntitlementSource` and never mentions the vendor; the
// adapter is the only code that knows both, and it turns the SDK's callback into `async` exactly once.
import Foundation

public enum CouplingPremiumGate {
    // MARK: The gate's own vocabulary

    public protocol EntitlementSource: Sendable {
        func activeEntitlements() async throws -> Set<String>
    }

    public struct Feature: Hashable, Sendable {
        public let name: String
        public let entitlement: String?

        public init(name: String, entitlement: String?) {
            self.name = name
            self.entitlement = entitlement
        }
    }

    public enum Access: Equatable, Sendable {
        case granted
        case locked
        case unknown
    }

    public actor Gate {
        private let source: any EntitlementSource
        private var lastKnown: Set<String>?

        public init(source: any EntitlementSource) {
            self.source = source
        }

        public func access(to feature: Feature) async -> Access {
            // Free features never need the source, so they work offline and cost nothing
            guard let required = feature.entitlement else { return .granted }
            let active: Set<String>
            do {
                active = try await source.activeEntitlements()
                lastKnown = active
            } catch {
                // Offline or the vendor is down: trust the last answer, and never show a paywall on a guess
                guard let remembered = lastKnown else { return .unknown }
                active = remembered
            }
            return active.contains(required) ? .granted : .locked
        }
    }

    // MARK: The vendor's SDK (simulated)

    public struct VendorEntitlement: Sendable {
        public let identifier: String
        public let isActive: Bool

        public init(identifier: String, isActive: Bool) {
            self.identifier = identifier
            self.isActive = isActive
        }
    }

    public struct VendorCustomerInfo: Sendable {
        public let entitlements: [String: VendorEntitlement]

        public init(entitlements: [String: VendorEntitlement]) {
            self.entitlements = entitlements
        }
    }

    public enum VendorError: Error, Equatable, Sendable {
        case network
        case notConfigured
    }

    public final class VendorPurchases: Sendable {
        private let answer: Result<VendorCustomerInfo, VendorError>

        public init(answering answer: Result<VendorCustomerInfo, VendorError>) {
            self.answer = answer
        }

        public func getCustomerInfo(completion: @escaping @Sendable (VendorCustomerInfo?, VendorError?) -> Void) {
            let answer = self.answer
            DispatchQueue.global().async {
                switch answer {
                case .success(let info): completion(info, nil)
                case .failure(let error): completion(nil, error)
                }
            }
        }
    }

    // MARK: The adapter

    public struct VendorEntitlementSource: EntitlementSource {
        private let purchases: VendorPurchases

        public init(purchases: VendorPurchases) {
            self.purchases = purchases
        }

        public func activeEntitlements() async throws -> Set<String> {
            let info: VendorCustomerInfo = try await withCheckedThrowingContinuation { continuation in
                purchases.getCustomerInfo { info, error in
                    if let info {
                        continuation.resume(returning: info)
                    } else {
                        continuation.resume(throwing: error ?? VendorError.network)
                    }
                }
            }
            return Set(info.entitlements.values.filter(\.isActive).map(\.identifier))
        }
    }
}

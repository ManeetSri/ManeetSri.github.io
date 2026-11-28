// Kata: Premium gate (D03 · Dependency direction and stable dependencies)
import DesignKit
import Foundation

public enum CouplingPremiumGate {
    // MARK: The gate's own vocabulary
    //
    // These types belong to the feature. They're named in the app's words, and nothing here mentions the
    // vendor, so the gate's rules don't change when the vendor's SDK does.

    /// What the gate needs from whatever knows the user's purchases: the entitlements active right now,
    /// such as `["pro"]`. Throws when it can't find out (offline, the vendor is down).
    public protocol EntitlementSource: Sendable {
        func activeEntitlements() async throws -> Set<String>
    }

    /// Something in the app that may sit behind a purchase
    public struct Feature: Hashable, Sendable {
        public let name: String
        /// The entitlement that unlocks it, or nil when the feature is free for everyone
        public let entitlement: String?

        public init(name: String, entitlement: String?) {
            self.name = name
            self.entitlement = entitlement
        }
    }

    /// What the screen should do
    public enum Access: Equatable, Sendable {
        /// Show the feature
        case granted
        /// Show the paywall: the check succeeded and the user doesn't have the entitlement
        case locked
        /// Show "can't check right now, try again": never a paywall for someone who may have paid
        case unknown
    }

    /// Decides whether a feature is available. Uses only `EntitlementSource`.
    public actor Gate {
        public init(source: any EntitlementSource) {
            // Write your solution here
        }

        /// - Free features are `.granted` without asking the source at all.
        /// - Otherwise ask the source. Granted if the feature's entitlement is active, `.locked` if not,
        ///   and remember the answer.
        /// - If the source throws, decide from the last answer it gave. With no answer yet, `.unknown`.
        public func access(to feature: Feature) async -> Access {
            // Write your solution here, then run:
            // swift test --filter CouplingPremiumGateTests
            return .locked
        }
    }

    // MARK: The vendor's SDK (simulated)
    //
    // Don't change this part: it stands for a third-party SDK you don't own. Like many real SDKs it has its
    // own vocabulary and an old-style completion handler. You construct it with the answer it should give.

    public struct VendorEntitlement: Sendable {
        public let identifier: String
        public let isActive: Bool

        public init(identifier: String, isActive: Bool) {
            self.identifier = identifier
            self.isActive = isActive
        }
    }

    public struct VendorCustomerInfo: Sendable {
        /// Every entitlement the user has ever had, active or not, keyed by identifier
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

        /// Calls back exactly once, on a background queue, with the info or an error
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
    //
    // The only code that knows both the gate's protocol and the vendor's SDK.

    public struct VendorEntitlementSource: EntitlementSource {
        public init(purchases: VendorPurchases) {
            // Write your solution here
        }

        /// The identifiers of the entitlements the vendor reports as active. Passes the vendor's error on;
        /// if the SDK ever answers with neither info nor an error, throw `VendorError.network`.
        public func activeEntitlements() async throws -> Set<String> {
            // Write your solution here
            throw Unimplemented()
        }
    }
}

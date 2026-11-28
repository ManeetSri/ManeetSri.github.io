// Problem: Referral chain (M04 · Optionals from lookups and conversions)

public enum ReferralChain {
    /// `referredBy[name]` is the person who referred `name`. Returns the person `steps` links up the
    /// chain from `person` (`person` itself when `steps` is 0), or nil if the chain ends sooner.
    public static func ancestor(of person: String, steps: Int, in referredBy: [String: String]) -> String? {
        // Write your solution here, then run:
        // swift test --filter ReferralChainTests
        return nil
    }
}

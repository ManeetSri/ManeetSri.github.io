// Reference solution: Referral chain. Follow one dictionary lookup per step; guard let stops with nil
// as soon as someone in the chain wasn't referred. O(steps) time, O(1) extra space.

public enum ReferralChain {
    public static func ancestor(of person: String, steps: Int, in referredBy: [String: String]) -> String? {
        var current = person
        for _ in stride(from: 0, to: steps, by: 1) {
            guard let referrer = referredBy[current] else {
                return nil
            }
            current = referrer
        }
        return current
    }
}

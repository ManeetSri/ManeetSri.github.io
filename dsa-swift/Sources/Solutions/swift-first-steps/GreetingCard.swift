// Reference solution: A greeting card. A multi-line string literal with interpolation;
// the quotes need no escaping inside """. O(n) time and space for a card of length n.

public enum GreetingCard {
    public static func card(to recipient: String, from sender: String, message: String) -> String {
        """
        To: \(recipient)
        "\(message)"
        From: \(sender)
        """
    }
}

// Generated from src/dsa/design/content/lessons/sd-coupling/sd-coupling-basics.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// What the server sends. Only this type knows the server's field names.
struct ProfileResponse: Decodable {
    let displayName: String
    let followerCount: Int

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"   // "user_name" until API v2: the only line that changed
        case followerCount = "followers"
    }
}

// What the app uses everywhere, named in the app's words
struct Profile {
    let name: String
    let followers: Int

    init(_ response: ProfileResponse) {
        name = response.displayName
        followers = response.followerCount
    }
}

let json = Data(#"{"display_name": "Ada", "followers": 1200}"#.utf8)
let profile = Profile(try JSONDecoder().decode(ProfileResponse.self, from: json))
print("\(profile.name) has \(profile.followers) followers")

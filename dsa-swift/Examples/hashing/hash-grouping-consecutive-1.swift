// Generated from src/dsa/content/lessons/hashing/hash-grouping-consecutive.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func normalised(_ email: String) -> String {
    let parts = email.lowercased().split(separator: "@", maxSplits: 1)
    guard parts.count == 2 else {
        return email.lowercased()
    }
    let local = parts[0].split(separator: "+", maxSplits: 1, omittingEmptySubsequences: false)[0]
    return local + "@" + parts[1]
}

let signUps = ["Asha@mail.com", "ben@site.org", "asha+shop@mail.com", "BEN@site.org", "cleo@mail.com", "asha@MAIL.com"]

var groupIndex: [String: Int] = [:]      // key -> position of its group in `groups`
var groups: [[String]] = []
for email in signUps {
    let key = normalised(email)
    if let index = groupIndex[key] {
        groups[index].append(email)
    } else {
        groupIndex[key] = groups.count   // a new group goes at the end
        groups.append([email])
    }
}
for group in groups {
    print(group)
}

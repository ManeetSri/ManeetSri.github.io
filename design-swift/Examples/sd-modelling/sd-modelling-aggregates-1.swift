// Generated from src/dsa/design/content/lessons/sd-modelling/sd-modelling-aggregates.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct UserID: Hashable, Sendable, CustomStringConvertible {
    let rawValue: String
    init(_ rawValue: String) { self.rawValue = rawValue }
    var description: String { rawValue }
}

/// A group chat's membership. The chat is the aggregate root: every change goes through it,
/// and it keeps the rules true after each one.
/// - Invariant: 1 to `maxMembers` members, nobody twice, and always at least one admin.
struct GroupChat: Identifiable, Sendable {
    enum Role: Sendable { case admin, member }

    struct Member: Equatable, Sendable {
        let user: UserID
        var role: Role
    }

    enum Problem: Error {
        case notAnAdmin(UserID)
        case alreadyMember(UserID)
        case notAMember(UserID)
        case full
        case lastMember
    }

    static let maxMembers = 256

    let id: UUID
    private(set) var members: [Member]      // in the order they joined
    private(set) var version = 1           // bumped by every change; sent to the server as If-Match

    init(id: UUID, createdBy creator: UserID) {
        self.id = id
        self.members = [Member(user: creator, role: .admin)]
    }

    mutating func add(_ user: UserID, by admin: UserID) throws {
        try requireAdmin(admin)
        guard !members.contains(where: { $0.user == user }) else { throw Problem.alreadyMember(user) }
        guard members.count < Self.maxMembers else { throw Problem.full }
        members.append(Member(user: user, role: .member))
        version += 1
    }

    mutating func remove(_ user: UserID, by admin: UserID) throws {
        try requireAdmin(admin)
        guard user != admin else { return try leave(admin) }
        guard let index = members.firstIndex(where: { $0.user == user }) else { throw Problem.notAMember(user) }
        members.remove(at: index)
        version += 1
    }

    mutating func leave(_ user: UserID) throws {
        guard let index = members.firstIndex(where: { $0.user == user }) else { throw Problem.notAMember(user) }
        guard members.count > 1 else { throw Problem.lastMember }
        members.remove(at: index)
        // The last admin left: the longest-standing member takes over, so the rule still holds
        if !members.contains(where: { $0.role == .admin }) {
            members[0].role = .admin
        }
        version += 1
    }

    private func requireAdmin(_ user: UserID) throws {
        guard members.contains(Member(user: user, role: .admin)) else { throw Problem.notAnAdmin(user) }
    }
}

let ana = UserID("ana"), ben = UserID("ben"), cy = UserID("cy"), dan = UserID("dan")
var chat = GroupChat(id: UUID(uuidString: "0B9E8C7D-6A5F-4E3D-8C2B-1A0F9E8D7C6B")!, createdBy: ana)
try chat.add(ben, by: ana)
try chat.add(cy, by: ana)
do {
    try chat.add(dan, by: ben)
} catch {
    print("Refused: \(error)")
}
try chat.leave(ana)
print(chat.members.map { "\($0.user): \($0.role)" }, "version \(chat.version)")
try chat.remove(cy, by: ben)
print(chat.members.map { "\($0.user): \($0.role)" }, "version \(chat.version)")

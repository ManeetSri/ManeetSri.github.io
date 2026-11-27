// Problem: Break the cycle (M11 · Retain cycles, weak and unowned references)

public enum PetAdoption {
    public final class Owner {
        public let name: String
        /// The owner's pet, if any. The owner should keep its pet alive.
        public var pet: Pet?

        public init(name: String) {
            self.name = name
        }

        /// Links this owner and `newPet` in both directions. If the owner already had a different pet,
        /// that pet no longer has an owner. If `newPet` already had a different owner, that owner no longer
        /// has a pet.
        public func adopt(_ newPet: Pet) {
            // Write your solution here, then run:
            // swift test --filter PetAdoptionTests
        }
    }

    public final class Pet {
        public let name: String
        /// The pet's owner, if any. This reference must not keep the owner alive.
        public var owner: Owner?

        public init(name: String) {
            self.name = name
        }
    }
}

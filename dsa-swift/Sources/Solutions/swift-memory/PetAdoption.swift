// Reference solution: Break the cycle. The owner holds its pet strongly and the pet points back weakly,
// so the pair never forms a retain cycle. Each adoption is O(1).

public enum PetAdoption {
    public final class Owner {
        public let name: String
        public var pet: Pet?

        public init(name: String) {
            self.name = name
        }

        public func adopt(_ newPet: Pet) {
            pet?.owner = nil          // my previous pet no longer has an owner
            newPet.owner?.pet = nil   // the pet's previous owner no longer has a pet
            pet = newPet
            newPet.owner = self
        }
    }

    public final class Pet {
        public let name: String
        public weak var owner: Owner?   // weak: the back-reference doesn't count

        public init(name: String) {
            self.name = name
        }
    }
}

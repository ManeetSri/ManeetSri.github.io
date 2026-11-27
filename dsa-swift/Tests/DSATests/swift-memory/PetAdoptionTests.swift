import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PetAdoptionTests {
    @Test("Adopting links owner and pet both ways")
    func linksBothWays() {
        let owner = PetAdoption.Owner(name: "Maneet")
        let pet = PetAdoption.Pet(name: "Biscuit")
        owner.adopt(pet)
        #expect(owner.pet === pet)
        #expect(pet.owner === owner)
    }

    @Test("Both are freed when nothing else holds them")
    func bothAreFreed() {
        weak var weakOwner: PetAdoption.Owner?
        weak var weakPet: PetAdoption.Pet?
        do {
            let owner = PetAdoption.Owner(name: "Maneet")
            let pet = PetAdoption.Pet(name: "Biscuit")
            owner.adopt(pet)
            weakOwner = owner
            weakPet = pet
        }
        #expect(weakOwner == nil, "The owner leaked: is there a retain cycle?")
        #expect(weakPet == nil, "The pet leaked: is there a retain cycle?")
    }

    @Test("A pet doesn't keep its owner alive")
    func petDoesNotKeepOwnerAlive() {
        let pet = PetAdoption.Pet(name: "Biscuit")
        do {
            let owner = PetAdoption.Owner(name: "Maneet")
            owner.adopt(pet)
            #expect(pet.owner?.name == "Maneet")
        }
        #expect(pet.owner == nil)
    }

    @Test("An owner keeps its pet alive")
    func ownerKeepsPetAlive() {
        let owner = PetAdoption.Owner(name: "Maneet")
        do {
            let pet = PetAdoption.Pet(name: "Biscuit")
            owner.adopt(pet)
        }
        #expect(owner.pet?.name == "Biscuit")
        #expect(owner.pet?.owner === owner)
    }

    @Test("A pet adopted by someone else leaves its first owner")
    func rehoming() {
        let first = PetAdoption.Owner(name: "Asha")
        let second = PetAdoption.Owner(name: "Ravi")
        let pet = PetAdoption.Pet(name: "Pepper")
        first.adopt(pet)
        second.adopt(pet)
        #expect(first.pet == nil)
        #expect(second.pet === pet)
        #expect(pet.owner === second)
    }

    @Test("An owner who adopts a new pet lets go of the old one")
    func newPetReplacesOld() {
        let owner = PetAdoption.Owner(name: "Maneet")
        let old = PetAdoption.Pet(name: "Biscuit")
        let new = PetAdoption.Pet(name: "Mango")
        owner.adopt(old)
        owner.adopt(new)
        #expect(old.owner == nil)
        #expect(owner.pet === new)
        #expect(new.owner === owner)
    }

    @Test("Adopting the same pet twice changes nothing")
    func adoptTwice() {
        let owner = PetAdoption.Owner(name: "Maneet")
        let pet = PetAdoption.Pet(name: "Biscuit")
        owner.adopt(pet)
        owner.adopt(pet)
        #expect(owner.pet === pet)
        #expect(pet.owner === owner)
    }
}

// Katas for D15 · Anti-patterns & refactoring
export default [
    {
        id: 'sd-kata-refactoring-delivery-fee',
        kind: 'problem',
        title: 'Refactor a delivery fee behind characterisation tests',
        difficulty: 'medium',
        patterns: ['principles', 'testing'],
        lessons: ['sd-refactoring-characterisation-tests', 'sd-refactoring-extract-protocol'],
        swiftTest: 'CharacterisedDeliveryFeeTests',
        lists: [],
        minutes: 30,
    },
    {
        id: 'sd-kata-refactoring-ride-types',
        kind: 'problem',
        title: 'Ride types: replace the switch with polymorphism',
        difficulty: 'easy',
        patterns: ['patterns', 'principles'],
        lessons: ['sd-refactoring-replace-conditional'],
        swiftTest: 'PolymorphicRideTypesTests',
        lists: [],
        minutes: 25,
    },
];

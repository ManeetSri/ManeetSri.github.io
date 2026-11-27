// Each problem's exercise stub from the Swift package, as text: what the solution editor starts from.
// Keyed by type name (FenwickSlotWalks), with the file's path inside Sources/Exercises.
const files = import.meta.glob('../../../dsa-swift/Sources/Exercises/**/*.swift', { query: '?raw', import: 'default' });

export default Object.fromEntries(Object.entries(files).map(([path, load]) => {
    const file = path.split('/Sources/Exercises/')[1];
    return [file.split('/').pop().replace(/\.swift$/, ''), { file, load }];
}));

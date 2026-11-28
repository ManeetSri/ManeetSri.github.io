// Each kata's exercise stub from design-swift, as text: what the solution editor starts from.
// Keyed by type name, with the file's path inside Sources/Exercises.
const files = import.meta.glob('../../../../design-swift/Sources/Exercises/**/*.swift', { query: '?raw', import: 'default' });

export default Object.fromEntries(Object.entries(files).map(([path, load]) => {
    const file = path.split('/Sources/Exercises/')[1];
    return [file.split('/').pop().replace(/\.swift$/, ''), { file, load }];
}));

// A glob of MDX files keyed by id: a file's name is its id, so files can move between folders
export const byId = (files) => Object.fromEntries(Object.entries(files).map(([path, load]) => [path.split('/').pop().replace(/\.mdx$/, ''), load]));

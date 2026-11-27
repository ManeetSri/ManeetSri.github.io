// Inserting keys into a small hash table, with separate chaining or linear probing.
// Integer keys hash to key % size; string keys use a simple polynomial hash so collisions are easy to follow.

export const hashOf = (key, size) => {
    if (typeof key === 'number') return ((key % size) + size) % size;
    let hash = 0;
    for (const character of String(key)) hash = (hash * 31 + character.charCodeAt(0)) % size;
    return hash;
};

export const hashExplanation = (key, size) => (typeof key === 'number'
    ? `${key} % ${size} = ${hashOf(key, size)}`
    : `hash("${key}") % ${size} = ${hashOf(key, size)}`);

export const hashTableFrames = (mode, keys, size) => {
    const frames = [];
    if (mode === 'chaining') {
        const buckets = Array.from({ length: size }, () => []);
        frames.push({ buckets: buckets.map((bucket) => [...bucket]), message: `${size} empty buckets. Each bucket holds a list of the keys that hash to it.` });
        keys.forEach((key) => {
            const index = hashOf(key, size);
            const collision = buckets[index].length > 0;
            buckets[index].push(key);
            frames.push({
                buckets: buckets.map((bucket) => [...bucket]),
                active: index,
                key,
                message: `${hashExplanation(key, size)}. ${collision ? `Bucket ${index} is taken, so ${key} joins its list: a collision.` : `Bucket ${index} was empty.`}`,
            });
        });
        const longest = Math.max(...buckets.map((bucket) => bucket.length));
        frames.push({ buckets: buckets.map((bucket) => [...bucket]), message: `Load factor ${keys.length}/${size} = ${(keys.length / size).toFixed(2)}. The longest list has ${longest} key${longest === 1 ? '' : 's'}: a lookup walks at most that many.` });
        return frames;
    }

    const slots = Array(size).fill(null);
    frames.push({ slots: [...slots], message: `${size} empty slots. A key that collides tries the next slot, and the next, until it finds a free one.` });
    for (const key of keys) {
        if (!slots.includes(null)) {
            frames.push({ slots: [...slots], key, message: `The table is full, so ${key} can't go in. Real tables grow and rehash before this happens.` });
            break;
        }
        const home = hashOf(key, size);
        let index = home;
        const probed = [];
        while (slots[index] !== null) {
            probed.push(index);
            index = (index + 1) % size;
        }
        slots[index] = key;
        frames.push({
            slots: [...slots],
            active: index,
            probed,
            key,
            message: `${hashExplanation(key, size)}. ${probed.length ? `Slot${probed.length > 1 ? 's' : ''} ${probed.join(', ')} ${probed.length > 1 ? 'are' : 'is'} taken, so ${key} lands in slot ${index} after ${probed.length} extra probe${probed.length > 1 ? 's' : ''}.` : `Slot ${index} was free.`}`,
        });
    }
    frames.push({ slots: [...slots], message: `Load factor ${slots.filter((slot) => slot !== null).length}/${size}. Notice the clusters: the fuller the table, the longer the probes.` });
    return frames;
};

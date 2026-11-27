// Inserting keys into a small hash table, with separate chaining, linear probing or quadratic probing.
// The probing modes also take operations ("insert 10", "find 17", "delete 10"), deleting with tombstones
// or, to show the trap, by emptying the slot.
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

export const hashTableFrames = (mode, keys, size, operations, deletion = 'tombstone') => {
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

    return probingFrames(mode, operations ?? keys.map((key) => `insert ${key}`), size, deletion);
};

// A deleted slot in an open-addressing table: "something was here, keep probing"
export const TOMBSTONE = Object.freeze({ tombstone: true });

const parse = (operation) => {
    const [op, value] = String(operation).trim().split(/\s+/);
    return [op, Number.isNaN(Number(value)) ? value : Number(value)];
};

const probingFrames = (mode, operations, size, deletion) => {
    const quadratic = mode === 'quadratic';
    const slotAt = (home, attempt) => (quadratic ? (home + attempt * attempt) % size : (home + attempt) % size);
    const stepWord = quadratic ? 'offsets 0, 1, 4, 9, … (i²)' : 'the next slot, and the next';
    const slots = Array(size).fill(null);
    const frames = [{ slots: [...slots], message: `${size} empty slots. A key that collides tries ${stepWord}, until it finds a free slot.` }];
    const extra = (probed) => (probed.length ? `${probed.length} extra probe${probed.length > 1 ? 's' : ''}` : 'no extra probes');

    // Walk the key's probe sequence. Stops at the key, at an empty slot, or after `size` attempts.
    const walk = (key) => {
        const home = hashOf(key, size);
        const probed = [];
        let firstTombstone = null;
        for (let attempt = 0; attempt < size; attempt += 1) {
            const index = slotAt(home, attempt);
            if (slots[index] === null) return { home, probed, index, found: false, firstTombstone };
            if (slots[index] === key) return { home, probed, index, found: true, firstTombstone };
            if (slots[index] === TOMBSTONE && firstTombstone === null) firstTombstone = index;
            probed.push(index);
        }
        return { home, probed, index: null, found: false, firstTombstone };
    };

    for (const operation of operations) {
        const [op, key] = parse(operation);
        const { home, probed, index, found, firstTombstone } = walk(key);
        const start = hashExplanation(key, size);
        if (op === 'insert') {
            if (found) {
                frames.push({ slots: [...slots], active: index, probed, key, op, message: `${start}. ${key} is already in slot ${index}, so nothing changes.` });
                continue;
            }
            const target = firstTombstone ?? index;
            if (target === null) {
                frames.push({ slots: [...slots], probed, key, op, message: quadratic && slots.includes(null)
                    ? `${start}. The probe sequence only ever visits slots ${[...new Set(probed)].join(', ')}, and they're all taken, so ${key} can't go in, even though ${slots.filter((slot) => slot === null).length} slots are free. Keep the table under half full with a prime size and this can't happen.`
                    : `${start}. Every slot is taken, so ${key} can't go in. Real tables grow and rehash before this happens.` });
                continue;
            }
            slots[target] = key;
            const before = probed.filter((slot) => slot !== target);
            frames.push({
                slots: [...slots],
                active: target,
                probed: before,
                key,
                op,
                message: `${start}. ${target === home ? `Slot ${home} was free.` : target === firstTombstone ? `The probe passes a tombstone in slot ${target} and finds no ${key} further on, so ${key} reuses the tombstone.` : `${key} lands in slot ${target} after ${extra(before)}.`}`,
            });
        } else if (op === 'find') {
            frames.push({ slots: [...slots], active: found ? index : undefined, probed, key, op, message: found
                ? `find(${key}): ${start}. Found in slot ${index} after ${extra(probed)}.`
                : `find(${key}): ${start}. ${index === null ? 'Every slot in the sequence was checked' : `Slot ${index} is empty, so the probe sequence ends here`}: ${key} isn't in the table.` });
        } else if (op === 'delete') {
            if (!found) {
                frames.push({ slots: [...slots], probed, key, op, message: `delete(${key}): ${start}. ${key} isn't in the table, so nothing to delete.` });
                continue;
            }
            slots[index] = deletion === 'empty' ? null : TOMBSTONE;
            frames.push({ slots: [...slots], active: index, probed, key, op, message: deletion === 'empty'
                ? `delete(${key}): empty slot ${index}. Careful: any key that probed past slot ${index} can no longer be found.`
                : `delete(${key}): slot ${index} becomes a tombstone. Lookups keep probing past it; inserts may reuse it.` });
        } else {
            throw new Error(`A hash table can't "${op}" (use insert, find or delete)`);
        }
    }
    const used = slots.filter((slot) => slot !== null && slot !== TOMBSTONE).length;
    const tombstones = slots.filter((slot) => slot === TOMBSTONE).length;
    frames.push({ slots: [...slots], message: `Load factor ${used}/${size}${tombstones ? `, plus ${tombstones} tombstone${tombstones > 1 ? 's' : ''} that still lengthen probes` : ''}. ${quadratic ? 'Quadratic jumps scatter keys from crowded neighbourhoods, but keys with the same home still share a path.' : 'Notice the clusters: the fuller the table, the longer the probes.'}` });
    return frames;
};

// A JSON backup of every collection, downloadable from Settings and importable on any device
import { COLLECTIONS } from './store.js';

const FORMAT = 'maneet-dsa-backup';
// Version 2 added design exercises (the `designs` collection). Older backups import with it empty.
const VERSION = 2;

export const exportBackup = (state) => {
    const backup = {
        format: FORMAT,
        version: VERSION,
        exportedAt: new Date().toISOString(),
        ...Object.fromEntries(COLLECTIONS.map((name) => [name, state[name]])),
    };
    const url = URL.createObjectURL(new Blob([JSON.stringify(backup, null, 2)], { type: 'application/json' }));
    const link = document.createElement('a');
    link.href = url;
    link.download = `dsa-progress-${backup.exportedAt.slice(0, 10)}.json`;
    link.click();
    setTimeout(() => URL.revokeObjectURL(url), 0);
};

const isMap = (value) => value !== null && typeof value === 'object' && !Array.isArray(value);

// Returns the collections to import, or throws a readable error
export const parseBackup = (text) => {
    let data;
    try {
        data = JSON.parse(text);
    } catch {
        throw new Error('That file isn’t valid JSON.');
    }
    if (data?.format !== FORMAT) throw new Error('That file isn’t a backup of this console.');
    if (data.version > VERSION) throw new Error('That backup comes from a newer version of the console.');
    return Object.fromEntries(COLLECTIONS.map((name) => {
        const docs = data[name] ?? {};
        if (!isMap(docs) || !Object.values(docs).every(isMap)) throw new Error(`The “${name}” section of the backup is damaged.`);
        return [name, docs];
    }));
};

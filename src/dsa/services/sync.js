// Sync for the console: Firestore with an offline cache. Loaded separately from sign-in (see firebase.js),
// because it's by far the largest part of Firebase.
import {
    clearIndexedDbPersistence,
    collection,
    deleteDoc,
    doc,
    getFirestore,
    initializeFirestore,
    onSnapshot,
    persistentLocalCache,
    persistentMultipleTabManager,
    setDoc,
    terminate,
} from '@firebase/firestore';
import { getFirebaseApp } from '../../firebase/app';

let db = null;

// Offline first: reads come from the local cache and writes queue until the network is back
const database = () => {
    if (db) return db;
    try {
        db = initializeFirestore(getFirebaseApp(), { localCache: persistentLocalCache({ tabManager: persistentMultipleTabManager() }) });
    } catch {
        db = getFirestore(getFirebaseApp());
    }
    return db;
};

// Stops syncing and wipes this device's offline copy. Used when the console is locked.
export const closeDatabase = async () => {
    if (!db) return;
    const current = db;
    db = null;
    await terminate(current);
    await clearIndexedDbPersistence(current).catch(() => {});
};

// Every document lives under dsa/{uid}/{collection}/{id}. Writes merge, so nested maps like a lesson's
// quiz answers combine across devices instead of replacing each other.
export const createFirestoreAdapter = (uid) => {
    const store = database();
    const pending = new Map();
    const statusListeners = new Set();
    let lastStatus = navigator.onLine ? 'synced' : 'offline';

    const notify = () => {
        const waiting = [...pending.values()].some(Boolean);
        const status = !navigator.onLine ? 'offline' : waiting ? 'pending' : 'synced';
        if (status === lastStatus) return;
        lastStatus = status;
        statusListeners.forEach((listener) => listener(status));
    };
    window.addEventListener('online', notify);
    window.addEventListener('offline', notify);

    return {
        subscribe: (name, callback) => onSnapshot(
            collection(store, 'dsa', uid, name),
            { includeMetadataChanges: true },
            (snapshot) => {
                pending.set(name, snapshot.metadata.hasPendingWrites);
                notify();
                callback(Object.fromEntries(snapshot.docs.map((item) => [item.id, item.data()])));
            },
            (error) => console.warn(`Sync stopped for ${name}:`, error.code ?? error),
        ),
        put: (name, id, patch) => setDoc(doc(store, 'dsa', uid, name, id), patch, { merge: true }),
        remove: (name, id) => deleteDoc(doc(store, 'dsa', uid, name, id)),
        onStatus: (listener) => {
            statusListeners.add(listener);
            listener(lastStatus);
            return () => statusListeners.delete(listener);
        },
        destroy: () => {
            window.removeEventListener('online', notify);
            window.removeEventListener('offline', notify);
        },
    };
};

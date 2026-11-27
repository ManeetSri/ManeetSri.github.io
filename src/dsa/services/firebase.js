// Sign-in and sync for the console. Loaded on demand, so none of this reaches the portfolio's bundle.
//
// initializeAuth without a popup/redirect resolver means no firebaseapp.com iframe and no extra scripts,
// so the site's frame-src 'none' policy holds. Email/password sign-in only talks to identitytoolkit
// and securetoken.
import {
    browserLocalPersistence,
    getAuth,
    indexedDBLocalPersistence,
    initializeAuth,
    onAuthStateChanged,
    signInWithEmailAndPassword,
    signOut,
} from '@firebase/auth';
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
import { OWNER_EMAIL } from './owner';

const app = getFirebaseApp();

const createAuth = () => {
    try {
        return initializeAuth(app, { persistence: [indexedDBLocalPersistence, browserLocalPersistence] });
    } catch {
        // Hot reload runs this module again. Auth is already set up by then, so this returns that instance.
        return getAuth(app);
    }
};

const auth = createAuth();
let db = null;

// Offline first: reads come from the local cache and writes queue until the network is back
const database = () => {
    if (db) return db;
    try {
        db = initializeFirestore(app, { localCache: persistentLocalCache({ tabManager: persistentMultipleTabManager() }) });
    } catch {
        db = getFirestore(app);
    }
    return db;
};

export const watchUser = (callback) => onAuthStateChanged(auth, callback);

export const unlock = (passphrase) => signInWithEmailAndPassword(auth, OWNER_EMAIL, passphrase);

// Signing out also wipes the offline copy from this device
export const lock = async () => {
    await signOut(auth);
    if (!db) return;
    const current = db;
    db = null;
    await terminate(current);
    await clearIndexedDbPersistence(current).catch(() => {});
};

const unlockMessages = {
    'auth/invalid-credential': 'That passphrase didn’t work.',
    'auth/wrong-password': 'That passphrase didn’t work.',
    'auth/user-not-found': 'The console account doesn’t exist yet. Create it in the Firebase console first.',
    'auth/too-many-requests': 'Too many tries. Wait a few minutes and try again.',
    'auth/network-request-failed': 'You seem to be offline. Connect once to unlock this device.',
};

export const unlockErrorMessage = (error) => unlockMessages[error?.code] ?? 'Something went wrong. Try again.';

// Every document lives under dsa/{uid}/{collection}/{id}. Writes merge, so nested maps like a lesson's
// quiz answers combine across devices instead of replacing each other.
export const createFirestoreAdapter = (uid) => {
    const store = database();
    const pending = new Map();
    const statusListeners = new Set();
    let lastStatus = 'synced';

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

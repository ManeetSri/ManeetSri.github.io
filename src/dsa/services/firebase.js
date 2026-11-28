// Sign-in for the console. Loaded on demand, so none of this reaches the portfolio's bundle.
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

// Firestore is most of the console's Firebase code, so it lives in ./sync.js and loads separately:
// the passphrase screen only needs Auth. Starting the download early means it's ready by sign-in.
export const loadSync = () => import('./sync.js');

export const watchUser = (callback) => onAuthStateChanged(auth, callback);

export const unlock = (passphrase) => signInWithEmailAndPassword(auth, OWNER_EMAIL, passphrase);

// Signing out also wipes the offline copy from this device
export const lock = async () => {
    await signOut(auth);
    await (await loadSync()).closeDatabase();
};

const unlockMessages = {
    'auth/invalid-credential': 'That passphrase didn’t work.',
    'auth/wrong-password': 'That passphrase didn’t work.',
    'auth/user-not-found': 'The console account doesn’t exist yet. Create it in the Firebase console first.',
    'auth/too-many-requests': 'Too many tries. Wait a few minutes and try again.',
    'auth/network-request-failed': 'You seem to be offline. Connect once to unlock this device.',
};

export const unlockErrorMessage = (error) => unlockMessages[error?.code] ?? 'Something went wrong. Try again.';

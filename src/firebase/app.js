import { getApp, getApps, initializeApp } from '@firebase/app';

// A Firebase web config identifies the project and isn't a secret. It ships to every browser.
const firebaseConfig = {
    apiKey: 'AIzaSyAF1GdZjcxOUXz3AJqh3joBGpYO_4LvRhc',
    authDomain: 'maneet-s-portfolio.firebaseapp.com',
    projectId: 'maneet-s-portfolio',
    storageBucket: 'maneet-s-portfolio.firebasestorage.app',
    messagingSenderId: '738041174226',
    appId: '1:738041174226:web:ee3a059211673b98b6750b',
    measurementId: 'G-BM8QH45DQG',
};

// Analytics and the learning console share one app. Whichever loads first creates it.
// Only dynamically loaded code imports this, so Firebase stays out of the main bundle.
export const getFirebaseApp = () => (getApps().length ? getApp() : initializeApp(firebaseConfig));

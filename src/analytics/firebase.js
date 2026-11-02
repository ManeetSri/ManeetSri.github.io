import { initializeApp } from 'firebase/app';
import { initializeAnalytics, isSupported, logEvent, setAnalyticsCollectionEnabled, setConsent, setUserProperties } from 'firebase/analytics';
import { getPerformance } from 'firebase/performance';

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

export const createClient = async () => {
    if (!(await isSupported())) return null;

    const app = initializeApp(firebaseConfig);

    // Measurement only: no advertising storage, personalization or Google Signals
    setConsent({
        analytics_storage: 'granted',
        ad_storage: 'denied',
        ad_user_data: 'denied',
        ad_personalization: 'denied',
    });
    const analytics = initializeAnalytics(app, {
        config: {
            allow_google_signals: false,
            allow_ad_personalization_signals: false,
        },
    });

    // Page load timing and Core Web Vitals, reported in Firebase's Performance dashboard
    const performance = getPerformance(app);

    return {
        log: (name, params) => logEvent(analytics, name, params),
        setUserProperties: (properties) => setUserProperties(analytics, properties),
        setEnabled: (enabled) => {
            setAnalyticsCollectionEnabled(analytics, enabled);
            performance.dataCollectionEnabled = enabled;
            performance.instrumentationEnabled = enabled;
        },
    };
};

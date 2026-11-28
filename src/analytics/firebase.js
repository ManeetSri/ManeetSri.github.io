import { initializeAnalytics, isSupported, logEvent, setAnalyticsCollectionEnabled, setConsent, setUserProperties } from '@firebase/analytics';
import { getPerformance } from '@firebase/performance';
import { getFirebaseApp } from '../firebase/app';

const toConsentSettings = ({ analytics, ads }) => ({
    analytics_storage: analytics ? 'granted' : 'denied',
    ad_storage: ads ? 'granted' : 'denied',
    ad_user_data: ads ? 'granted' : 'denied',
    ad_personalization: ads ? 'granted' : 'denied',
});

export const createClient = async (consent) => {
    if (!(await isSupported())) return null;

    const app = getFirebaseApp();

    // Signals and ad personalization are allowed here, and the visitor's consent decides if they run
    setConsent(toConsentSettings(consent));
    const analytics = initializeAnalytics(app, {
        config: {
            allow_google_signals: true,
            allow_ad_personalization_signals: true,
        },
    });

    // Page load timing and Core Web Vitals, reported in Firebase's Performance dashboard
    const performance = getPerformance(app);

    return {
        log: (name, params) => logEvent(analytics, name, params),
        setUserProperties: (properties) => setUserProperties(analytics, properties),
        setConsent: (choice) => setConsent(toConsentSettings(choice)),
        setEnabled: (enabled) => {
            setAnalyticsCollectionEnabled(analytics, enabled);
            performance.dataCollectionEnabled = enabled;
            performance.instrumentationEnabled = enabled;
        },
    };
};

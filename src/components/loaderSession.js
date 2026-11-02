const SESSION_KEY = 'maneet-build-played';

export const shouldPlayLoader = (hash) => {
    if (hash || window.matchMedia('(prefers-reduced-motion: reduce)').matches) return false;
    try {
        return !sessionStorage.getItem(SESSION_KEY);
    } catch {
        return true;
    }
};

export const markPlayed = () => {
    try {
        sessionStorage.setItem(SESSION_KEY, '1');
    } catch {
        // Without storage the build simply plays again on the next visit
    }
};

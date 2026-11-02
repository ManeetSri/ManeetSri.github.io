import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

const SETTLE_MS = 2500;
const USER_SCROLL_EVENTS = ['wheel', 'touchstart', 'keydown'];

const ScrollToTop = () => {
    const { pathname, hash } = useLocation();

    useEffect(() => {
        // Jump instantly so the global smooth scrolling doesn't animate between pages
        const target = hash && document.getElementById(hash.slice(1));
        if (!target) {
            window.scrollTo({ top: 0, behavior: 'instant' });
            return undefined;
        }
        target.scrollIntoView({ behavior: 'instant' });

        // Content above can still grow, like the articles loading, so stay on target until it
        // settles or the visitor starts scrolling themselves
        const observer = new ResizeObserver(() => target.scrollIntoView({ behavior: 'instant' }));
        observer.observe(document.body);
        const stop = () => {
            observer.disconnect();
            clearTimeout(timer);
            USER_SCROLL_EVENTS.forEach((name) => window.removeEventListener(name, stop));
        };
        const timer = setTimeout(stop, SETTLE_MS);
        USER_SCROLL_EVENTS.forEach((name) => window.addEventListener(name, stop, { passive: true }));
        return stop;
    }, [pathname, hash]);

    return null;
};

export default ScrollToTop;

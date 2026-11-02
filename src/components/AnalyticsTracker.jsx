import { useEffect, useRef } from 'react';
import { useLocation } from 'react-router-dom';
import { startAnalytics, track } from '../analytics';

const SECTIONS = ['top', 'journey', 'work', 'skills', 'services', 'notes', 'contact'];
const SCROLL_MARKS = [25, 50, 75, 100];
const MIN_SECTION_SECONDS = 2;
const EVENT_PREFIX = 'event';

// <a data-event="cta_click" data-event-cta="resume"> logs cta_click with { cta: 'resume' }
const paramsFrom = (dataset) => Object.fromEntries(
    Object.entries(dataset)
        .filter(([key]) => key.startsWith(EVENT_PREFIX) && key !== EVENT_PREFIX)
        .map(([key, value]) => [key.slice(EVENT_PREFIX.length).toLowerCase(), value]),
);

// Page-wide measurements. Google Analytics itself counts the first page view and engagement time.
const AnalyticsTracker = () => {
    const { pathname } = useLocation();
    const previousPath = useRef(pathname);

    // Moving between pages inside the app doesn't load a new document, so it's logged here.
    // The timeout lets the new page set its title first.
    useEffect(() => {
        if (previousPath.current === pathname) return undefined;
        previousPath.current = pathname;
        const timer = setTimeout(() => {
            track('page_view', { page_location: window.location.href, page_title: document.title });
        }, 0);
        return () => clearTimeout(timer);
    }, [pathname]);

    useEffect(() => {
        startAnalytics();

        const onClick = (event) => {
            const element = event.target.closest?.('[data-event]');
            if (element) track(element.dataset.event, paramsFrom(element.dataset));
        };
        const onError = (event) => {
            track('exception', { description: String(event.message), fatal: false });
        };
        const onRejection = (event) => {
            track('exception', { description: String(event.reason?.message ?? event.reason), fatal: false });
        };

        document.addEventListener('click', onClick);
        window.addEventListener('error', onError);
        window.addEventListener('unhandledrejection', onRejection);
        return () => {
            document.removeEventListener('click', onClick);
            window.removeEventListener('error', onError);
            window.removeEventListener('unhandledrejection', onRejection);
        };
    }, []);

    // How far each page gets read
    useEffect(() => {
        const reached = new Set();
        const onScroll = () => {
            const scrollable = document.documentElement.scrollHeight - window.innerHeight;
            if (scrollable <= 0) return;
            const percent = (window.scrollY / scrollable) * 100;
            SCROLL_MARKS.filter((mark) => percent >= mark - 0.5 && !reached.has(mark)).forEach((mark) => {
                reached.add(mark);
                track('scroll_depth', { percent: mark, page: pathname });
            });
        };
        window.addEventListener('scroll', onScroll, { passive: true });
        return () => window.removeEventListener('scroll', onScroll);
    }, [pathname]);

    // Which home page sections are seen, and how long people stay on each
    useEffect(() => {
        if (pathname !== '/') return undefined;

        const seen = new Set();
        let current = null;
        let enteredAt = 0;

        const leaveCurrent = () => {
            if (!current) return;
            const seconds = Math.round((performance.now() - enteredAt) / 1000);
            if (seconds >= MIN_SECTION_SECONDS) track('section_time', { section: current, seconds });
            current = null;
        };

        const observer = new IntersectionObserver((entries) => {
            entries.filter((entry) => entry.isIntersecting).forEach((entry) => {
                leaveCurrent();
                current = entry.target.id;
                enteredAt = performance.now();
                if (!seen.has(current)) {
                    seen.add(current);
                    track('section_view', { section: current });
                }
            });
        }, { rootMargin: '-50% 0px -50% 0px' });

        SECTIONS.forEach((id) => {
            const section = document.getElementById(id);
            if (section) observer.observe(section);
        });

        const onHide = () => {
            if (document.visibilityState === 'hidden') {
                const section = current;
                leaveCurrent();
                current = section;
                enteredAt = performance.now();
            }
        };
        document.addEventListener('visibilitychange', onHide);

        return () => {
            leaveCurrent();
            observer.disconnect();
            document.removeEventListener('visibilitychange', onHide);
        };
    }, [pathname]);

    return null;
};

export default AnalyticsTracker;

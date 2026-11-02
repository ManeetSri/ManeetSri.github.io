import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

const ScrollToTop = () => {
    const { pathname, hash } = useLocation();

    useEffect(() => {
        // Jump instantly so the global smooth scrolling doesn't animate between pages
        const target = hash && document.getElementById(hash.slice(1));
        if (target) {
            target.scrollIntoView({ behavior: 'instant' });
        } else {
            window.scrollTo({ top: 0, behavior: 'instant' });
        }
    }, [pathname, hash]);

    return null;
};

export default ScrollToTop;

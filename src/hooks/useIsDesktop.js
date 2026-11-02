import { useEffect, useState } from 'react';

const DESKTOP_QUERY = '(min-width: 1024px)';

export const useIsDesktop = () => {
    const [isDesktop, setIsDesktop] = useState(() => window.matchMedia(DESKTOP_QUERY).matches);

    useEffect(() => {
        const media = window.matchMedia(DESKTOP_QUERY);
        const onChange = (event) => setIsDesktop(event.matches);
        media.addEventListener('change', onChange);
        return () => media.removeEventListener('change', onChange);
    }, []);

    return isDesktop;
};

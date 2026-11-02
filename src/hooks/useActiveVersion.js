import { useState } from 'react';
import { useMotionValueEvent, useScroll } from 'framer-motion';

// The latest release note to reach the middle of the page, worked out from the scroll
// position so it stays right after a jump from the tab bar
export const useActiveVersion = () => {
    const [activeIndex, setActiveIndex] = useState(0);
    const { scrollY } = useScroll();

    useMotionValueEvent(scrollY, 'change', () => {
        const notes = [...document.querySelectorAll('#journey ol > li')];
        const reached = notes.filter((note) => note.getBoundingClientRect().top <= window.innerHeight * 0.475);
        setActiveIndex(Math.max(0, reached.length - 1));
    });

    return activeIndex;
};

import { motion, useScroll, useSpring } from 'framer-motion';

// The page's scroll position, drawn as an Xcode build progress bar
const ScrollProgress = () => {
    const { scrollYProgress } = useScroll();
    const scaleX = useSpring(scrollYProgress, { stiffness: 200, damping: 40, restDelta: 0.0002 });

    return (
        <motion.div
            aria-hidden="true"
            style={{ scaleX }}
            className="swift-gradient fixed inset-x-0 top-0 z-40 h-[3px] origin-left"
        />
    );
};

export default ScrollProgress;

import { Suspense } from 'react';
import { easeIn, easeOut, motion, useTransform } from 'framer-motion';
import HomeScreen from './HomeScreen';
import { SCENES } from './scenes';
import { CLOSE, ICON_SIZE, LAUNCH, iconPosition, segments } from '../../data/workTimeline';

const holdStill = (value) => value;
const OPEN_AND_CLOSE = { ease: [easeOut, holdStill, easeIn] };

const SceneLayer = ({ segment, index, p, active, onFocusScene }) => {
    const { start, end, project } = segment;

    // Opens from the app's home screen icon and closes back into it
    const scale = useTransform(p, [start, start + LAUNCH, end - CLOSE, end], [0.18, 1, 1, 0.18], OPEN_AND_CLOSE);
    const opacity = useTransform(p, [start, start + LAUNCH * 0.4, end - CLOSE * 0.5, end], [0, 1, 1, 0]);
    const sceneProgress = useTransform(p, [start + LAUNCH, end - CLOSE], [0, 1]);

    const { x, y } = iconPosition(index);
    const isActive = active === index;
    const shouldMount = project.interactive || Math.abs(active - index) <= 1;
    if (!shouldMount) return null;

    const Scene = SCENES[project.id];

    return (
        <motion.div
            onFocus={project.interactive && !isActive ? () => onFocusScene(index) : undefined}
            style={{
                scale,
                opacity,
                transformOrigin: `${x + ICON_SIZE / 2}px ${y + ICON_SIZE / 2}px`,
                pointerEvents: isActive && project.interactive ? 'auto' : 'none',
            }}
            className="absolute inset-0 overflow-hidden rounded-[2.65rem] will-change-transform"
        >
            <Suspense fallback={<div className="absolute inset-0 bg-surface" />}>
                <Scene p={sceneProgress} />
            </Suspense>
        </motion.div>
    );
};

const WorkScreens = ({ p, active, onFocusScene }) => (
    <>
        <HomeScreen />
        {segments.map((segment, index) => (
            <SceneLayer
                key={segment.project.id}
                segment={segment}
                index={index}
                p={p}
                active={active}
                onFocusScene={onFocusScene}
            />
        ))}
    </>
);

export default WorkScreens;

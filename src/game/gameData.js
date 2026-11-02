import { useEffect, useRef } from 'react';
import { features, platforms } from '../data/services';
import { projects } from '../data/projects';

// The real apps that already use the chosen features
export const proofFor = (selected) => {
    const ids = new Set(features.filter((feature) => selected.includes(feature.id)).flatMap((feature) => feature.proof));
    return projects.filter((project) => ids.has(project.id));
};

export const stackFor = (platform, selected) => [
    ...platforms.find((item) => item.id === platform).stack,
    ...features.filter((feature) => selected.includes(feature.id)).map((feature) => feature.stack),
];

// Levels animate in after the old one leaves, so focus has to move when the new heading mounts
export const useFocusOnMount = () => {
    const ref = useRef(null);
    useEffect(() => {
        ref.current?.focus({ preventScroll: true });
    }, []);
    return ref;
};

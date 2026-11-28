import { lazy, Suspense, useMemo } from 'react';
import { VISUALS } from '../viz/registry.js';

// Created once, so React keeps each visualiser's state between renders
const VIEWS = Object.fromEntries(Object.entries(VISUALS).map(([name, load]) => [name, lazy(load)]));

// A ```visual <name> block. The visualiser's code loads the first time a lesson shows it.
const Visual = ({ data }) => {
    // Parsed once per block, so the visualiser gets the same props on every render
    const { name, props } = useMemo(() => JSON.parse(data), [data]);
    const View = VIEWS[name];
    return (
        <Suspense fallback={<div className="my-8 h-64 animate-pulse rounded-2xl border border-line bg-surface" />}>
            <View {...props} />
        </Suspense>
    );
};

export default Visual;

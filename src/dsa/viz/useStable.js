import { useMemo } from 'react';

// Lesson props are parsed afresh on each render. This keeps the same object while its contents stay the
// same, so a view's useMemo only rebuilds its frames when the props really change.
export const useStable = (value) => {
    const key = JSON.stringify(value ?? null);
    return useMemo(() => JSON.parse(key), [key]);
};

export default useStable;

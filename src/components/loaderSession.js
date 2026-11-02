// Lives in memory, so a refresh plays the loader again but moving between pages doesn't
let played = false;
let playing = false;
const listeners = new Set();

export const shouldPlayLoader = (hash) => {
    if (played || hash) return false;
    return !window.matchMedia('(prefers-reduced-motion: reduce)').matches;
};

export const loaderStarted = () => {
    played = true;
    playing = true;
};

export const loaderFinished = () => {
    playing = false;
    listeners.forEach((listener) => listener());
};

export const isLoaderPlaying = () => playing;

export const onLoaderFinished = (listener) => {
    listeners.add(listener);
    return () => listeners.delete(listener);
};

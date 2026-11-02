// Lives in memory, so a refresh plays the loader again but moving between pages doesn't
let played = false;

export const shouldPlayLoader = (hash) => {
    if (played || hash) return false;
    return !window.matchMedia('(prefers-reduced-motion: reduce)').matches;
};

export const markPlayed = () => {
    played = true;
};

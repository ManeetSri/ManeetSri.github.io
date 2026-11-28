// Spaced repetition, SM-2-lite. Each card gets an ease factor and an interval in days. "Again" brings a
// card back today, the other ratings push it further out: roughly 1 → 3 → 8 → 20 → 50 days on "Good".
import { addDays, endOfDay, startOfDay } from './dates.js';

export const RATINGS = ['again', 'hard', 'good', 'easy'];

const START_EASE = 2.5;
const MIN_EASE = 1.3;
const AGAIN_DELAY_MS = 10 * 60_000;

export const newCard = (fields, now) => ({
    ...fields,
    ease: START_EASE,
    interval: 0,
    reps: 0,
    lapses: 0,
    reviews: 0,
    due: now,
    last: null,
});

const nextInterval = (card, rating) => {
    const { interval, reps, ease } = card;
    if (rating === 'hard') return reps === 0 ? 1 : Math.max(interval + 1, Math.round(interval * 1.2));
    if (rating === 'easy') return reps === 0 ? 3 : Math.max(interval + 1, Math.round(interval * ease * 1.3));
    if (reps === 0) return 1;
    if (reps === 1) return 3;
    return Math.max(interval + 1, Math.round(interval * ease));
};

export const reviewCard = (card, rating, now) => {
    if (!RATINGS.includes(rating)) throw new Error(`Unknown rating "${rating}"`);
    const reviews = (card.reviews ?? 0) + 1;

    if (rating === 'again') {
        return {
            ...card,
            ease: Math.max(MIN_EASE, card.ease - 0.2),
            interval: 0,
            reps: 0,
            lapses: card.lapses + 1,
            reviews,
            due: now + AGAIN_DELAY_MS,
            last: now,
        };
    }

    const interval = nextInterval(card, rating);
    const easeChange = { hard: -0.15, good: 0, easy: 0.15 }[rating];
    return {
        ...card,
        ease: Math.max(MIN_EASE, card.ease + easeChange),
        interval,
        reps: card.reps + 1,
        reviews,
        due: startOfDay(addDays(now, interval)),
        last: now,
    };
};

// A card is due any time on its due day
export const isDue = (card, now) => card.due <= endOfDay(now);

export const dueCards = (cards, now) => Object.entries(cards)
    .filter(([, card]) => isDue(card, now))
    .sort(([, a], [, b]) => a.due - b.due)
    .map(([id, card]) => ({ id, ...card }));

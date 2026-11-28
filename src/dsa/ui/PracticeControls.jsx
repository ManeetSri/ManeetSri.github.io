import { Pause, Play, RotateCcw } from 'lucide-react';
import { reviewCard, RATINGS } from '../engine/srs.js';
import { formatDuration } from './format.js';
import { Button } from './primitives.jsx';

const RATING_LABELS = { again: 'Again', hard: 'Hard', good: 'Good', easy: 'Easy' };

const intervalLabel = (card) => (card.interval === 0 ? '<10m' : `${card.interval}d`);

const NEW_CARD = { ease: 2.5, interval: 0, reps: 0, lapses: 0 };

export const Stopwatch = ({ seconds, running, onToggle, onReset, target }) => (
    <div className="flex flex-wrap items-center gap-2">
        <span className="min-w-16 font-mono text-2xl tabular-nums" aria-label={`Timer ${formatDuration(seconds)}`}>{formatDuration(seconds)}</span>
        {target && <span className="font-mono text-xs text-muted">of ~{target} min</span>}
        <Button size="sm" onClick={onToggle} aria-label={running ? 'Pause the timer' : 'Start the timer'}>
            {running ? <Pause size={15} aria-hidden="true" /> : <Play size={15} aria-hidden="true" />} {running ? 'Pause' : 'Start'}
        </Button>
        <Button size="sm" variant="ghost" onClick={onReset} aria-label="Reset the timer"><RotateCcw size={15} aria-hidden="true" /></Button>
    </div>
);

// The four spaced-repetition ratings, each showing when the item would come back
export const RatingPicker = ({ card, value, onChange, now, legend = 'When should it come back?' }) => {
    const preview = card ?? NEW_CARD;
    return (
        <fieldset>
            <legend className="mb-2 text-sm font-medium">{legend}</legend>
            <div className="grid grid-cols-4 gap-1.5">
                {RATINGS.map((key) => (
                    <button key={key} type="button" aria-pressed={value === key} aria-label={`${RATING_LABELS[key]}, back in ${intervalLabel(reviewCard(preview, key, now))}`} onClick={() => onChange(key)} className={`rounded-xl px-1 py-2 text-center text-sm ${value === key ? 'bg-amber/20 text-amber ring-1 ring-amber' : 'bg-white/[0.05] text-muted hover:text-paper'}`}>
                        <span className="block font-medium">{RATING_LABELS[key]}</span>
                        <span className="block font-mono text-[11px] opacity-80">{intervalLabel(reviewCard(preview, key, now))}</span>
                    </button>
                ))}
            </div>
        </fieldset>
    );
};

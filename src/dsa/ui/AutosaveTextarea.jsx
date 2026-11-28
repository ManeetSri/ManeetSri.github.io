import { useEffect, useRef, useState } from 'react';

const SAVE_DELAY_MS = 700;

// Saves a moment after typing stops, so every keystroke isn't a write. `onInput` hears every change.
export const AutosaveTextarea = ({ initial, onSave, onInput, label, placeholder, rows = 5, mono = false }) => {
    const [text, setText] = useState(initial ?? '');
    const [saved, setSaved] = useState(true);
    const timer = useRef(null);
    const unsaved = useRef(null);
    const save = useRef(onSave);

    useEffect(() => {
        save.current = onSave;
    });

    // Leaving the page mid-sentence still saves what was typed
    useEffect(() => () => {
        clearTimeout(timer.current);
        if (unsaved.current !== null) save.current(unsaved.current);
    }, []);

    const change = (value) => {
        onInput?.(value);
        setText(value);
        unsaved.current = value;
        setSaved(false);
        clearTimeout(timer.current);
        timer.current = setTimeout(() => {
            save.current(value);
            unsaved.current = null;
            setSaved(true);
        }, SAVE_DELAY_MS);
    };

    return (
        <div>
            <textarea
                value={text}
                onChange={(event) => change(event.target.value)}
                rows={rows}
                aria-label={label}
                placeholder={placeholder}
                spellCheck={!mono}
                className={`w-full rounded-xl border border-line bg-white/[0.04] p-3 leading-relaxed outline-none focus:border-amber ${mono ? 'font-mono text-[13px]' : 'text-sm'}`}
            />
            <p className="mt-1 text-right font-mono text-[11px] text-muted" aria-live="polite">{saved ? (text ? 'Saved' : '') : 'Saving…'}</p>
        </div>
    );
};

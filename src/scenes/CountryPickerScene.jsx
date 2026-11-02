import { useEffect, useMemo, useRef, useState } from 'react';
import { motion, useMotionValueEvent, useReducedMotion } from 'framer-motion';
import { Check, Search } from 'lucide-react';
import { Scene } from './shared';
import { countries, flagFor } from '../data/countries';

const ACCENT = '#FF7A59';
const DEMO_QUERY = '+91';
const DEBOUNCE_MS = 220;

const detectRegion = () => {
    try {
        const region = new Intl.Locale(navigator.language).region;
        return countries.some((country) => country.iso === region) ? region : 'IN';
    } catch {
        return 'IN';
    }
};

const matches = (country, query) => {
    const term = query.trim().toLowerCase();
    if (!term) return true;
    return country.name.toLowerCase().includes(term)
        || country.iso.toLowerCase() === term
        || country.dial.includes(term);
};

const CountryPickerScene = ({ p }) => {
    const reduceMotion = useReducedMotion();
    const [query, setQuery] = useState('');
    const [debounced, setDebounced] = useState('');
    const [selected, setSelected] = useState(detectRegion);
    const [highlight, setHighlight] = useState(0);
    const touched = useRef(false);

    useEffect(() => {
        const timer = setTimeout(() => setDebounced(query), DEBOUNCE_MS);
        return () => clearTimeout(timer);
    }, [query]);

    const results = useMemo(() => countries.filter((country) => matches(country, debounced)), [debounced]);

    // Types a demo search as you scroll, until the visitor takes over
    useMotionValueEvent(p, 'change', (value) => {
        if (touched.current || reduceMotion) return;
        const characters = Math.floor(Math.min(value / 0.35, 1) * DEMO_QUERY.length);
        const next = DEMO_QUERY.slice(0, characters);
        setQuery(next);
        setDebounced(next);
    });

    const select = (country) => {
        setSelected(country.iso);
        navigator.vibrate?.(10);
    };

    const onKeyDown = (event) => {
        if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
            event.preventDefault();
            const step = event.key === 'ArrowDown' ? 1 : -1;
            setHighlight((index) => Math.max(0, Math.min(results.length - 1, index + step)));
        } else if (event.key === 'Enter' && results[highlight]) {
            event.preventDefault();
            select(results[highlight]);
        }
    };

    const current = countries.find((country) => country.iso === selected);

    return (
        <Scene background="#14100e" interactive>
            <div className="flex h-full flex-col px-3.5">
                <p className="text-[22px] font-bold">Select country</p>
                <p className="mb-2.5 truncate text-[13px] text-white/70">
                    {flagFor(current.iso)} {current.name} {current.dial}
                </p>
                <label className="mb-2 flex items-center gap-2 rounded-xl bg-white/10 px-3 py-2">
                    <Search size={15} aria-hidden="true" className="shrink-0 text-white/65" />
                    <span className="sr-only">Search countries by name, ISO code or dial code</span>
                    <input
                        type="search"
                        role="combobox"
                        aria-expanded="true"
                        aria-controls="country-results"
                        aria-activedescendant={results[highlight] ? `country-${results[highlight].iso}` : undefined}
                        autoComplete="off"
                        value={query}
                        placeholder="Name, ISO or dial code"
                        onChange={(event) => {
                            touched.current = true;
                            setQuery(event.target.value);
                            setHighlight(0);
                        }}
                        onKeyDown={onKeyDown}
                        className="w-full min-w-0 bg-transparent text-[16px] text-white placeholder:text-white/55 focus:outline-none"
                    />
                </label>
                <ul id="country-results" role="listbox" aria-label="Countries" className="min-h-0 flex-1 overflow-y-auto">
                    {results.map((country, index) => {
                        const isSelected = country.iso === selected;
                        return (
                            <li
                                key={country.iso}
                                id={`country-${country.iso}`}
                                role="option"
                                aria-selected={isSelected}
                                onClick={() => select(country)}
                                className={`flex cursor-pointer items-center gap-2.5 rounded-xl px-2 py-2 text-[14px] ${index === highlight ? 'bg-white/10' : ''}`}
                                style={isSelected ? { color: ACCENT } : undefined}
                            >
                                <span aria-hidden="true" className="text-[18px]">{flagFor(country.iso)}</span>
                                <span className="min-w-0 flex-1 truncate">{country.name}</span>
                                <span className="text-[13px] text-white/65">{country.dial}</span>
                                {isSelected && (
                                    <motion.span key={country.iso} initial={{ scale: 0 }} animate={{ scale: 1 }}>
                                        <Check size={16} aria-hidden="true" />
                                    </motion.span>
                                )}
                            </li>
                        );
                    })}
                    {results.length === 0 && <li className="py-6 text-center text-[14px] text-white/65">No countries found</li>}
                </ul>
            </div>
        </Scene>
    );
};

export default CountryPickerScene;

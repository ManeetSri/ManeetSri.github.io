import { useEffect, useRef, useState } from 'react';
import { animate, motion, useMotionValue, useMotionValueEvent, useReducedMotion, useTransform } from 'framer-motion';
import { Car, Check, MapPin, RotateCcw } from 'lucide-react';
import { track } from '../analytics';

const MAP_WIDTH = 360;
const MAP_HEIGHT = 400;
const PICKUP = { x: 70, y: 340 };
const FINDING_MS = 900;
const DRIVE_SECONDS = 5;

const DESTINATIONS = [
    { id: 'mall', name: 'Mall', minutes: 8, x: 70, y: 62, route: 'M70 340 C95 300 35 245 70 185 S50 110 70 62' },
    { id: 'office', name: 'Office', minutes: 12, x: 190, y: 90, route: 'M70 340 C70 280 150 295 160 230 S125 130 190 90' },
    { id: 'airport', name: 'Airport', minutes: 24, x: 310, y: 62, route: 'M70 340 C140 340 200 335 250 270 S325 160 310 62' },
];

const STREETS = [
    'M-10 120 C80 150 200 90 370 130',
    'M-10 290 C90 250 220 330 370 270',
    'M60 -10 C40 120 110 280 70 410',
    'M250 -10 C280 120 180 300 260 410',
    'M-10 370 C100 340 220 400 370 360',
];

const STEPS = ['Ride requested', 'Driver assigned', 'On the way', 'Arrived'];

// Measures a route once, so the car can be placed anywhere along it
const measure = (route) => {
    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('d', route);
    const length = path.getTotalLength();
    return (progress) => {
        const point = path.getPointAtLength(progress * length);
        return { x: (point.x / MAP_WIDTH) * 100, y: (point.y / MAP_HEIGHT) * 100 };
    };
};
const POSITIONS = Object.fromEntries(DESTINATIONS.map(({ id, route }) => [id, measure(route)]));

const RideDemo = ({ onArrive }) => {
    const reduceMotion = useReducedMotion();
    const [destinationId, setDestinationId] = useState(null);
    const [phase, setPhase] = useState('idle');
    const [percent, setPercent] = useState(0);
    const progress = useMotionValue(0);
    const driveRef = useRef(null);
    const timerRef = useRef(null);
    const scrubbedRef = useRef(false);

    const destination = DESTINATIONS.find((item) => item.id === destinationId);
    const hasArrived = percent >= 100;
    const stepIndex = phase === 'idle' ? -1 : phase === 'finding' ? 0 : hasArrived ? 3 : percent > 0 ? 2 : 1;
    const minutesLeft = destination ? Math.max(1, Math.ceil(destination.minutes * (1 - percent / 100))) : 0;

    const carLeft = useTransform(progress, (value) => `${(destinationId ? POSITIONS[destinationId](value).x : (PICKUP.x / MAP_WIDTH) * 100)}%`);
    const carTop = useTransform(progress, (value) => `${(destinationId ? POSITIONS[destinationId](value).y : (PICKUP.y / MAP_HEIGHT) * 100)}%`);

    useMotionValueEvent(progress, 'change', (value) => setPercent(Math.round(value * 100)));

    const stopDriving = () => {
        driveRef.current?.stop();
        clearTimeout(timerRef.current);
    };

    useEffect(() => stopDriving, []);

    useEffect(() => {
        if (hasArrived && destinationId) {
            track('ride_complete', { destination: destinationId });
            onArrive?.();
        }
        // Only arriving should trigger this, not a new callback from the parent
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [hasArrived, destinationId]);

    const startRide = (id) => {
        track('ride_request', { destination: id });
        stopDriving();
        setDestinationId(id);
        setPhase('finding');
        progress.jump(0);
        setPercent(0);
        timerRef.current = setTimeout(() => {
            setPhase('driving');
            driveRef.current = animate(progress, 1, { duration: reduceMotion ? 0 : DRIVE_SECONDS, ease: 'easeInOut' });
        }, reduceMotion ? 0 : FINDING_MS);
    };

    const scrub = (event) => {
        if (!scrubbedRef.current) {
            scrubbedRef.current = true;
            track('ride_scrub', { destination: destinationId });
        }
        stopDriving();
        setPhase('driving');
        progress.set(Number(event.target.value) / 100);
    };

    const reset = () => {
        stopDriving();
        setDestinationId(null);
        setPhase('idle');
        progress.jump(0);
        setPercent(0);
    };

    return (
        <div className="overflow-hidden rounded-[2rem] border border-line bg-surface select-none lg:grid lg:grid-cols-[minmax(0,1fr)_minmax(0,1fr)]">
            <div className="map-grid relative w-full" style={{ aspectRatio: `${MAP_WIDTH} / ${MAP_HEIGHT}` }}>
                <svg aria-hidden="true" viewBox={`0 0 ${MAP_WIDTH} ${MAP_HEIGHT}`} className="absolute inset-0 h-full w-full">
                    {STREETS.map((street) => (
                        <path key={street} d={street} fill="none" stroke="rgba(255,255,255,0.12)" strokeWidth="10" />
                    ))}
                    {DESTINATIONS.map(({ id, route }) => (
                        <path key={id} d={route} fill="none" stroke={id === destinationId ? 'rgba(48,209,88,0.25)' : 'rgba(255,255,255,0.08)'} strokeWidth="6" strokeLinecap="round" strokeDasharray={id === destinationId ? undefined : '2 10'} />
                    ))}
                    {destination && (
                        <motion.path d={destination.route} fill="none" stroke="#30D158" strokeWidth="6" strokeLinecap="round" style={{ pathLength: progress }} />
                    )}
                    <circle cx={PICKUP.x} cy={PICKUP.y} r="7" fill="#fff" stroke="#30D158" strokeWidth="4" />
                </svg>

                {DESTINATIONS.map((item) => {
                    const isChosen = item.id === destinationId;
                    return (
                        <button
                            key={item.id}
                            type="button"
                            onClick={() => startRide(item.id)}
                            aria-label={`Request a sample ride to ${item.name}`}
                            aria-pressed={isChosen}
                            className="absolute flex min-h-11 min-w-11 -translate-x-1/2 -translate-y-1/2 flex-col items-center justify-center"
                            style={{ left: `${(item.x / MAP_WIDTH) * 100}%`, top: `${(item.y / MAP_HEIGHT) * 100}%` }}
                        >
                            {phase === 'idle' && <span aria-hidden="true" className="absolute h-9 w-9 animate-ping rounded-full bg-amber/30 motion-reduce:animate-none" />}
                            <MapPin size={26} aria-hidden="true" className={`relative ${isChosen ? 'fill-[#30D158]/30 text-[#30D158]' : 'text-amber'}`} />
                            <span className={`relative mt-0.5 rounded-full px-2 py-0.5 text-xs font-semibold ${isChosen ? 'bg-[#30D158] text-ink' : 'bg-black/80 text-paper'}`}>{item.name}</span>
                        </button>
                    );
                })}

                <motion.span
                    aria-hidden="true"
                    style={{ left: carLeft, top: carTop }}
                    className="absolute flex h-9 w-9 -translate-x-1/2 -translate-y-1/2 items-center justify-center rounded-full bg-white shadow-lg shadow-black/50"
                >
                    <Car size={20} className="text-black" />
                </motion.span>

                <p className="phone-ui absolute left-1/2 top-3 -translate-x-1/2 whitespace-nowrap rounded-full bg-black/85 px-3 py-1.5 text-[13px] font-semibold" aria-live="polite">
                    {!destination && 'Tap a destination'}
                    {destination && phase === 'finding' && 'Finding a driver…'}
                    {destination && phase === 'driving' && !hasArrived && <>ETA <span className="text-[#30D158]">{minutesLeft} min</span></>}
                    {destination && hasArrived && <span className="text-[#30D158]">Arrived at {destination.name}</span>}
                </p>
            </div>

            <div className="flex flex-col p-4 sm:p-5">
                <div aria-hidden="true" className="mb-4 hidden lg:block">
                    <p className="font-mono text-sm text-muted">{destination ? 'Heading to' : 'Where to?'}</p>
                    <p className="font-display text-4xl font-semibold tracking-tight">{destination ? destination.name : 'Pick a pin'}</p>
                    <p className="mt-1 text-[#30D158]">
                        {phase === 'finding' && 'Finding a driver…'}
                        {phase === 'driving' && !hasArrived && `${minutesLeft} min away`}
                        {hasArrived && 'You have arrived'}
                        {phase === 'idle' && <span className="text-muted">On the map</span>}
                    </p>
                </div>

                <label className="block">
                    <span className="mb-1 block text-sm text-muted">Drag to move through the trip</span>
                    <input
                        type="range"
                        min="0"
                        max="100"
                        value={percent}
                        disabled={!destination}
                        onChange={scrub}
                        className="h-11 w-full cursor-pointer accent-[#30D158] disabled:cursor-not-allowed disabled:opacity-40"
                    />
                </label>

                <ol className="mt-1 grid grid-cols-4 gap-1.5">
                    {STEPS.map((step, index) => (
                        <li key={step} className="text-center">
                            <span className={`mx-auto mb-1 flex h-6 w-6 items-center justify-center rounded-full transition-colors duration-300 ${index <= stepIndex ? 'bg-[#30D158] text-ink' : 'bg-white/10 text-transparent'}`}>
                                <Check size={14} strokeWidth={3} aria-hidden="true" />
                            </span>
                            <span className={`block text-xs leading-tight ${index <= stepIndex ? 'text-paper' : 'text-muted'}`}>{step}</span>
                        </li>
                    ))}
                </ol>

                <div className="mt-4 flex items-center justify-between gap-3 border-t border-line pt-3 lg:mt-auto">
                    <p className="text-xs leading-snug text-muted">An illustrative demo with sample places. The real thing runs in Alyte.</p>
                    <button
                        type="button"
                        onClick={reset}
                        data-event="ride_reset"
                        disabled={!destination}
                        className="flex h-11 shrink-0 items-center gap-1.5 rounded-full bg-white/8 px-3.5 text-sm font-medium transition-colors hover:bg-white/15 disabled:opacity-40"
                    >
                        <RotateCcw size={15} aria-hidden="true" /> Reset
                    </button>
                </div>
            </div>
        </div>
    );
};

export default RideDemo;

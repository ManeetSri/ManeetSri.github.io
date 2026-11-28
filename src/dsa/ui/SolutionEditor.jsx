import { useEffect, useRef, useState } from 'react';
import { Download, FolderInput, LoaderCircle, RotateCcw } from 'lucide-react';
import { loadStarter } from '../content/index.js';
import { useCourse } from '../course/context.js';
import { CopyButton } from '../mdx/CodeBlock.jsx';
import { useActions, useCourseStore } from '../store/store.js';
import { CodeEditor } from './CodeEditor.jsx';
import { Button } from './primitives.jsx';

const SAVE_DELAY_MS = 700;

const download = (name, text) => {
    const url = URL.createObjectURL(new Blob([text], { type: 'text/x-swift' }));
    const link = Object.assign(document.createElement('a'), { href: url, download: name });
    link.click();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
};

// Development only: writes the code into the exercise stub, so `swift test` runs it (see scripts/dsa-exercise-writer.js)
const writeToPackage = async (pkg, file, code) => {
    const response = await fetch('/__dsa/exercise', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-DSA-Exercise': '1' },
        body: JSON.stringify({ package: pkg, file, code }),
    });
    if (!response.ok) throw new Error(await response.text());
};

// Your solution, written on the page. It starts as the problem's exercise stub and autosaves with the rest of
// your progress, so it follows you between devices. Only code that differs from the stub is stored.
export const SolutionEditor = ({ problem, compact = false }) => {
    const course = useCourse();
    const { problems, ready } = useCourseStore();
    const actions = useActions();
    const stored = problems[problem.id]?.solution ?? '';
    const [starter, setStarter] = useState({ status: 'loading' });
    const [text, setText] = useState(null);
    const [saving, setSaving] = useState(false);
    const [confirmReset, setConfirmReset] = useState(false);
    const [packageStatus, setPackageStatus] = useState(null);
    const [adopted, setAdopted] = useState(null);
    const [ownSaves, setOwnSaves] = useState([]);
    const pending = useRef(null);
    const timer = useRef(null);
    const persist = useRef(null);

    const starterCode = starter.status === 'ready' ? starter.code : '';
    useEffect(() => {
        persist.current = (value) => actions.saveProblemText(problem.id, 'solution', value === starterCode ? '' : value);
    });

    useEffect(() => {
        let cancelled = false;
        loadStarter(course, problem)
            .then((loaded) => !cancelled && setStarter(loaded ? { status: 'ready', ...loaded } : { status: 'missing' }))
            .catch(() => !cancelled && setStarter({ status: 'error' }));
        return () => {
            cancelled = true;
        };
    }, [course, problem]);

    // Between edits, the editor takes in whatever is stored: progress that loads late, or an edit made on
    // another device. An echo of one of your own earlier saves, arriving after you've typed more, is ignored.
    const external = ready && starter.status !== 'loading' ? stored || starterCode : null;
    if (external !== null && external !== adopted && !saving) {
        setAdopted(external);
        if (!ownSaves.includes(external) || external === ownSaves.at(-1)) setText(external);
    }

    const flush = () => {
        clearTimeout(timer.current);
        if (pending.current !== null) {
            persist.current(pending.current);
            const saved = pending.current;
            setOwnSaves((list) => [...list.slice(-4), saved]);
        }
        pending.current = null;
        setSaving(false);
    };

    // Leaving the page mid-edit still saves it
    useEffect(() => () => {
        clearTimeout(timer.current);
        if (pending.current !== null) persist.current(pending.current);
    }, []);

    const change = (value) => {
        pending.current = value;
        setText(value);
        setSaving(true);
        setConfirmReset(false);
        setPackageStatus(null);
        clearTimeout(timer.current);
        timer.current = setTimeout(flush, SAVE_DELAY_MS);
    };

    const reset = () => {
        clearTimeout(timer.current);
        pending.current = null;
        setText(starterCode);
        persist.current(starterCode);
        setOwnSaves((list) => [...list.slice(-4), starterCode]);
        setSaving(false);
        setConfirmReset(false);
    };

    const sendToPackage = async () => {
        flush();
        setPackageStatus({ busy: true });
        try {
            await writeToPackage(course.swift.package, starter.file, text);
            setPackageStatus({ message: `Written to Sources/Exercises/${starter.file}. Run the tests now.` });
        } catch (error) {
            setPackageStatus({ message: `Couldn’t write the file: ${error.message || 'the dev server refused'}.`, failed: true });
        }
    };

    const typeName = problem.swiftTest.replace(/Tests$/, '');
    const loading = text === null;
    const isStarter = text === starterCode;

    return (
        <div>
            <div className="mb-2 flex flex-wrap items-center gap-x-2 gap-y-1">
                <p className={`font-semibold ${compact ? 'text-sm' : ''}`}>Your solution</p>
                <span className="font-mono text-xs text-muted">{typeName}.swift</span>
                <span className="ml-auto flex items-center">
                    {!loading && <CopyButton text={text} />}
                    {!loading && (
                        <button type="button" onClick={() => download(`${typeName}.swift`, text)} className="inline-flex h-8 items-center gap-1.5 rounded-full px-2.5 text-xs text-muted hover:bg-white/8 hover:text-paper">
                            <Download size={14} aria-hidden="true" /> Download
                        </button>
                    )}
                    {!loading && starter.status === 'ready' && !isStarter && !confirmReset && (
                        <button type="button" onClick={() => setConfirmReset(true)} className="inline-flex h-8 items-center gap-1.5 rounded-full px-2.5 text-xs text-muted hover:bg-white/8 hover:text-paper">
                            <RotateCcw size={14} aria-hidden="true" /> Reset
                        </button>
                    )}
                </span>
            </div>

            {confirmReset && (
                <div className="mb-2 flex flex-wrap items-center gap-2 rounded-xl bg-[#FF9D96]/10 px-3 py-2 text-sm" role="alert">
                    <span className="flex-1">Replace your code with the starter code? This can’t be undone.</span>
                    <Button size="sm" variant="ghost" onClick={() => setConfirmReset(false)}>Keep my code</Button>
                    <Button size="sm" onClick={reset}>Reset</Button>
                </div>
            )}

            {loading
                ? <p className="flex h-40 items-center justify-center gap-2 rounded-xl border border-line bg-[#101217] text-sm text-muted" role="status"><LoaderCircle size={16} aria-hidden="true" className="animate-spin" /> Loading the starter code…</p>
                : <CodeEditor value={text} onChange={change} onSave={flush} label={`Swift solution for ${problem.title}`} />}

            <div className="mt-1.5 flex flex-wrap items-center gap-x-3 gap-y-1 font-mono text-[11px] text-muted">
                <span aria-live="polite">{loading ? '' : saving ? 'Saving…' : isStarter ? 'Starter code' : 'Saved'}</span>
                {starter.status === 'error' && <span className="text-[#FF9D96]">The starter code didn’t load</span>}
                <span className="ml-auto hidden sm:inline">⌘S or Ctrl+S saves · Esc, then Tab, leaves the editor</span>
            </div>

            {import.meta.env.DEV && starter.status === 'ready' && !loading && (
                <div className="mt-3 flex flex-wrap items-center gap-2">
                    <Button size="sm" onClick={sendToPackage} disabled={packageStatus?.busy}>
                        <FolderInput size={15} aria-hidden="true" /> Save to package
                    </Button>
                    <span className={`text-xs ${packageStatus?.failed ? 'text-[#FF9D96]' : 'text-muted'}`} aria-live="polite">
                        {packageStatus?.message ?? `Dev server only: overwrites Sources/Exercises/${starter.file}.`}
                    </span>
                </div>
            )}
        </div>
    );
};

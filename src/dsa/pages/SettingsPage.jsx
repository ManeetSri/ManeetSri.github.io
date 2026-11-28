import { useContext, useRef, useState } from 'react';
import { Compass, Download, LogOut, Trash2, Upload } from 'lucide-react';
import { useCourse } from '../course/context.js';
import { exportBackup, parseBackup } from '../store/exportImport.js';
import { StoreContext, useActions, useProfile, useStore } from '../store/store.js';
import { useConsoleMeta } from '../ui/hooks.js';
import { Button, ButtonLink, Card, PageHeader } from '../ui/primitives.jsx';

const MINUTE_OPTIONS = [15, 30, 45, 60, 90, 120];

const Section = ({ title, detail, children }) => (
    <Card className="p-5 sm:p-6">
        <h2 className="font-semibold">{title}</h2>
        {detail && <p className="mt-1 text-sm text-muted">{detail}</p>}
        <div className="mt-4">{children}</div>
    </Card>
);

const Segmented = ({ label, options, value, onChange }) => (
    <div role="radiogroup" aria-label={label} className="flex flex-wrap gap-2">
        {options.map((option) => (
            <button
                key={option.value}
                type="button"
                role="radio"
                aria-checked={value === option.value}
                onClick={() => onChange(option.value)}
                className={`h-10 rounded-full px-4 text-sm ${value === option.value ? 'bg-amber/20 font-medium text-amber ring-1 ring-amber' : 'bg-white/[0.06] text-muted hover:text-paper'}`}
            >
                {option.label}
            </button>
        ))}
    </div>
);

const SettingsPage = () => {
    const course = useCourse();
    const { GOALS, links, placementName } = course;
    useConsoleMeta('Settings', links.settings);
    const state = useStore();
    const profile = useProfile();
    const actions = useActions();
    const { lock } = useContext(StoreContext);
    const fileInput = useRef(null);
    const [message, setMessage] = useState('');
    const [confirmReset, setConfirmReset] = useState('');
    const [confirmCourseReset, setConfirmCourseReset] = useState('');

    const importFile = async (file) => {
        if (!file) return;
        try {
            const data = parseBackup(await file.text());
            if (!window.confirm('Import this backup? It merges into your current progress, and matching items are replaced by the backup’s version.')) return;
            await actions.importAll(data);
            setMessage('Backup imported.');
        } catch (error) {
            setMessage(error.message);
        } finally {
            fileInput.current.value = '';
        }
    };

    const resetCourse = async () => {
        await actions.resetCourse(course);
        setConfirmCourseReset('');
        setMessage(`${course.title} progress deleted.`);
    };

    const reset = async () => {
        await actions.resetAll();
        setConfirmReset('');
        setMessage('All progress was deleted.');
    };

    return (
        <div className="mx-auto max-w-3xl space-y-5">
            <PageHeader title="Settings" />

            <Section title="Guided setup" detail={`Go through goal, pace and the optional ${placementName} again.`}>
                <ButtonLink to={links.start}><Compass size={17} aria-hidden="true" /> Redo setup</ButtonLink>
            </Section>

            <Section title="Your goal" detail="It decides which lessons make up your main path. Everything else stays open as side quests.">
                <div role="radiogroup" aria-label="Goal" className="grid gap-2 sm:grid-cols-2">
                    {Object.entries(GOALS).map(([key, goal]) => (
                        <button
                            key={key}
                            type="button"
                            role="radio"
                            aria-checked={profile.goal === key}
                            onClick={() => actions.saveCourseProfile(course, { goal: key })}
                            className={`rounded-xl border p-4 text-left ${profile.goal === key ? 'border-amber bg-amber/10' : 'border-line hover:border-white/25'}`}
                        >
                            <span className="block font-medium">{goal.label}</span>
                            <span className="mt-0.5 block text-sm text-muted">{goal.detail}</span>
                        </button>
                    ))}
                </div>
            </Section>

            <Section title="Your pace" detail="Today’s plan fits into your daily minutes, and your finish date follows from both.">
                <p className="mb-2 text-sm">Minutes a day</p>
                <Segmented label="Minutes a day" value={profile.minutesPerDay} onChange={(value) => actions.saveCourseProfile(course, { minutesPerDay: value })} options={MINUTE_OPTIONS.map((value) => ({ value, label: `${value}` }))} />
                <p className="mb-2 mt-5 text-sm">Days a week</p>
                <Segmented label="Days a week" value={profile.daysPerWeek} onChange={(value) => actions.saveCourseProfile(course, { daysPerWeek: value })} options={[3, 4, 5, 6, 7].map((value) => ({ value, label: `${value}` }))} />
                <label className="mt-5 block text-sm">
                    Target date <span className="text-muted">(optional)</span>
                    <input
                        type="date"
                        value={profile.targetDate ?? ''}
                        onChange={(event) => actions.saveCourseProfile(course, { targetDate: event.target.value || null })}
                        className="mt-2 block h-10 rounded-xl border border-line bg-surface px-3 text-paper outline-none [color-scheme:dark] focus:border-amber"
                    />
                </label>
            </Section>

            <Section title="Reading">
                <p className="mb-2 text-sm">Lesson text size</p>
                <Segmented label="Lesson text size" value={profile.textSize} onChange={(value) => actions.saveProfile({ textSize: value })} options={[{ value: 'normal', label: 'Normal' }, { value: 'large', label: 'Large' }]} />
            </Section>

            <Section title="Backup" detail="Download everything as a JSON file, or bring a backup back in.">
                <div className="flex flex-wrap gap-2">
                    <Button onClick={() => exportBackup(state)}><Download size={17} aria-hidden="true" /> Export progress</Button>
                    <Button onClick={() => fileInput.current.click()}><Upload size={17} aria-hidden="true" /> Import a backup</Button>
                    <input ref={fileInput} type="file" accept="application/json,.json" hidden onChange={(event) => importFile(event.target.files[0])} />
                </div>
                <p aria-live="polite" className="mt-3 text-sm text-muted">{message}</p>
            </Section>

            <Section title={`Start ${course.title} over`} detail={`Deletes this course’s lessons, answers, attempts, cards, notes and settings from all your devices. Other courses, your streak and your study minutes stay. Export a backup first.`}>
                <label className="block text-sm">
                    Type <span className="font-mono text-swift">delete</span> to confirm
                    <input value={confirmCourseReset} onChange={(event) => setConfirmCourseReset(event.target.value)} className="mt-2 block h-10 w-full max-w-xs rounded-xl border border-line bg-surface px-3 outline-none focus:border-swift" />
                </label>
                <Button className="mt-3" onClick={resetCourse} disabled={confirmCourseReset !== 'delete'}><Trash2 size={17} aria-hidden="true" /> Delete {course.shortTitle} progress</Button>
            </Section>

            <Section title="Danger zone" detail="Deleting everything removes every course’s lessons, answers, attempts, cards and notes from all your devices. Export a backup first.">
                <label className="block text-sm">
                    Type <span className="font-mono text-swift">delete</span> to confirm
                    <input value={confirmReset} onChange={(event) => setConfirmReset(event.target.value)} className="mt-2 block h-10 w-full max-w-xs rounded-xl border border-line bg-surface px-3 outline-none focus:border-swift" />
                </label>
                <Button className="mt-3" onClick={reset} disabled={confirmReset !== 'delete'}><Trash2 size={17} aria-hidden="true" /> Delete everything</Button>
            </Section>

            <Section title="This device" detail="Locking signs out here and clears the offline copy. Your progress stays safe in your account.">
                <Button onClick={lock}><LogOut size={17} aria-hidden="true" /> Lock the console</Button>
            </Section>
        </div>
    );
};

export default SettingsPage;

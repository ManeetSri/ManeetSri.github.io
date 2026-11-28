import { useEffect, useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ArrowLeft, ArrowRight, Award, Bookmark, CheckCircle2, Clock3, Code2, Flag, LoaderCircle, RotateCcw } from 'lucide-react';
import { useCourse } from '../course/context.js';
import { useContent } from '../content/index.js';
import { mdxComponents } from '../mdx/components.js';
import { LessonContext } from '../mdx/lessonContext.js';
import { useActions, useCourseStore, useProfile } from '../store/store.js';
import { formatMinutes } from '../ui/format.js';
import { lessonContext, useConsoleMeta, usePath } from '../ui/hooks.js';
import { Button, ButtonLink, Card, Chip, EmptyState } from '../ui/primitives.jsx';
import { AutosaveTextarea } from '../ui/AutosaveTextarea.jsx';
import ConsoleNotFound from './ConsoleNotFound.jsx';

const OnThisPage = ({ headings }) => {
    const [active, setActive] = useState(null);

    useEffect(() => {
        const elements = headings.map((heading) => document.getElementById(heading.id)).filter(Boolean);
        if (!elements.length) return undefined;
        const observer = new IntersectionObserver((entries) => {
            const visible = entries.filter((entry) => entry.isIntersecting).sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
            if (visible[0]) setActive(visible[0].target.id);
        }, { rootMargin: '-15% 0px -70% 0px' });
        elements.forEach((element) => observer.observe(element));
        return () => observer.disconnect();
    }, [headings]);

    if (!headings.length) return null;
    return (
        <nav aria-label="On this page">
            <p className="mb-2 font-mono text-xs uppercase tracking-wider text-muted">On this page</p>
            <ul className="space-y-1 border-l border-line">
                {headings.map((heading) => (
                    <li key={heading.id}>
                        <a href={`#${heading.id}`} className={`-ml-px block border-l py-1 pl-3 text-sm ${active === heading.id ? 'border-amber text-paper' : 'border-transparent text-muted hover:text-paper'}`}>{heading.text}</a>
                    </li>
                ))}
            </ul>
        </nav>
    );
};

const Practice = ({ lesson }) => {
    const { practiceById, DIFFICULTIES, links } = useCourse();
    const { problems } = useCourseStore();
    const list = lesson.problems.map((id) => practiceById[id]).filter(Boolean);
    if (!list.length) return null;
    return (
        <section aria-labelledby="practice-problems" className="mt-12">
            <h2 id="practice-problems" className="mb-3 font-display text-[1.75rem] font-semibold tracking-tight">Practice problems</h2>
            <ul className="space-y-2">
                {list.map((problem) => {
                    const status = problems[problem.id]?.status;
                    return (
                        <li key={problem.id}>
                            <Link to={links.item(problem.id)} className="flex items-center gap-3 rounded-2xl border border-line bg-surface px-4 py-3.5 hover:border-white/25">
                                <Code2 size={18} aria-hidden="true" className="shrink-0 text-amber" />
                                <span className="min-w-0 flex-1 font-medium">{problem.title}</span>
                                {status === 'solved' && <Chip tone="green">solved</Chip>}
                                <Chip>{DIFFICULTIES[problem.difficulty].label}</Chip>
                                <ArrowRight size={16} aria-hidden="true" className="shrink-0 text-muted" />
                            </Link>
                        </li>
                    );
                })}
            </ul>
        </section>
    );
};

const PlannedLesson = ({ lesson, module, part }) => (
    <div className="space-y-6">
        <EmptyState icon={Clock3} title="This lesson is planned">
            Part {part.number}, “{part.title}”, is written in delivery phase {part.phase}. Here’s where it fits in the module.
        </EmptyState>
        <Card className="p-5">
            <p className="font-semibold">{module.code} · {module.title}</p>
            <p className="mt-1 text-sm text-muted">{module.summary}</p>
            <ol className="mt-4 space-y-1.5 text-sm">
                {module.lessons.map((item, index) => (
                    <li key={item.id} className={`flex gap-3 ${item.id === lesson.id ? 'text-amber' : 'text-paper/80'}`}>
                        <span className="w-5 font-mono text-xs text-muted">{index + 1}</span> {item.title}
                    </li>
                ))}
            </ol>
        </Card>
    </div>
);

const LessonView = ({ lesson }) => {
    const course = useCourse();
    const { lessons: allLessons, LEVELS, TRACKS, links } = course;
    useConsoleMeta(lesson.title, links.lesson(lesson.id));
    const content = useContent('lesson', lesson.id);
    const { lessons: progress, notes } = useCourseStore();
    const actions = useActions();
    const { textSize } = useProfile();
    const path = usePath();
    const { module, part } = lessonContext(lesson, course);
    const record = progress[lesson.id];
    const done = Boolean(record?.completedAt);

    const index = allLessons.indexOf(lesson);
    const previous = allLessons[index - 1];
    const next = path.find((item) => allLessons.indexOf(item) > index) ?? allLessons[index + 1];
    const context = useMemo(() => ({ lessonId: lesson.id }), [lesson.id]);

    useEffect(() => {
        if (content.status === 'ready') actions.openLesson(lesson.id);
    }, [content.status, lesson.id, actions]);

    const { Content, data } = content;

    return (
        <div className="mx-auto max-w-6xl xl:grid xl:grid-cols-[minmax(0,1fr)_220px] xl:gap-12">
            <article className={`min-w-0 max-w-3xl ${textSize === 'large' ? 'text-[1.125rem]' : ''}`}>
                <nav aria-label="Breadcrumb" className="mb-4 flex flex-wrap items-center gap-1.5 font-mono text-xs text-muted">
                    <Link to={links.path} className="hover:text-paper">Part {part.number}</Link>
                    <span aria-hidden="true">›</span>
                    <span>{module.code} {module.title}</span>
                    <span aria-hidden="true">›</span>
                    <span>Lesson {module.lessons.indexOf(lesson) + 1} of {module.lessons.length}</span>
                </nav>
                <h1 className="font-display text-[clamp(2rem,5vw,3rem)] font-semibold leading-[1.08] tracking-tight">{lesson.title}</h1>
                <div className="mt-4 flex flex-wrap items-center gap-2">
                    <Chip tone="amber">{LEVELS[lesson.level]}</Chip>
                    <Chip>{formatMinutes(lesson.minutes)}</Chip>
                    {lesson.tracks.map((track) => <Chip key={track}>{TRACKS[track]}</Chip>)}
                    {done && <Chip tone="green"><CheckCircle2 size={12} aria-hidden="true" /> Done</Chip>}
                    {!done && record?.testedOutAt && <Chip tone="green">Tested out</Chip>}
                    <span className="ml-auto flex gap-1">
                        <button type="button" onClick={() => actions.toggleFlag('lessons', lesson.id, 'bookmarked')} aria-pressed={Boolean(record?.bookmarked)} aria-label="Bookmark this lesson" className={`flex h-9 w-9 items-center justify-center rounded-full hover:bg-white/8 ${record?.bookmarked ? 'text-amber' : 'text-muted'}`}>
                            <Bookmark size={17} aria-hidden="true" fill={record?.bookmarked ? 'currentColor' : 'none'} />
                        </button>
                        <button type="button" onClick={() => actions.toggleFlag('lessons', lesson.id, 'confusing')} aria-pressed={Boolean(record?.confusing)} aria-label="Flag this lesson as confusing" className={`flex h-9 w-9 items-center justify-center rounded-full hover:bg-white/8 ${record?.confusing ? 'text-swift' : 'text-muted'}`}>
                            <Flag size={17} aria-hidden="true" fill={record?.confusing ? 'currentColor' : 'none'} />
                        </button>
                    </span>
                </div>

                <div className="mt-8">
                    {content.status === 'missing' && <PlannedLesson lesson={lesson} module={module} part={part} />}
                    {content.status === 'loading' && <p className="flex items-center gap-2 text-muted" role="status"><LoaderCircle size={18} aria-hidden="true" className="animate-spin" /> Loading the lesson…</p>}
                    {content.status === 'error' && <EmptyState title="The lesson didn’t load">Check your connection and open it again.</EmptyState>}
                    {content.status === 'ready' && (
                        <LessonContext.Provider value={context}>
                            <Content components={mdxComponents} />
                        </LessonContext.Provider>
                    )}
                </div>

                {content.status === 'ready' && (
                    <>
                        <Practice lesson={lesson} />

                        {module.lessons.at(-1) === lesson && (
                            <Card className="mt-12 flex flex-wrap items-center gap-4 border-amber/40 p-5">
                                <Award size={26} aria-hidden="true" className="shrink-0 text-amber" />
                                <div className="min-w-48 flex-1">
                                    <p className="font-semibold">That’s the end of {module.code}, {module.title}</p>
                                    <p className="text-sm text-muted">Take the checkpoint: 12 questions from the whole module. Score 80% to master it.</p>
                                </div>
                                <ButtonLink to={links.checkpoint(module.id)} size="sm" variant="primary">Take the checkpoint</ButtonLink>
                            </Card>
                        )}

                        <section aria-labelledby="lesson-notes" className="mt-12">
                            <h2 id="lesson-notes" className="mb-3 font-display text-[1.75rem] font-semibold tracking-tight">Your notes</h2>
                            <AutosaveTextarea key={lesson.id} initial={notes[lesson.id]?.text} onSave={(text) => actions.saveNote(lesson.id, text)} label="Notes for this lesson" placeholder="What clicked? What’s still fuzzy? Write it in your own words." />
                        </section>

                        <div className="mt-10 flex flex-wrap items-center gap-3 rounded-2xl border border-line bg-surface p-4 sm:p-5">
                            {done ? (
                                <>
                                    <p className="flex flex-1 items-center gap-2 font-medium text-[#30D158]"><CheckCircle2 size={20} aria-hidden="true" /> Lesson complete</p>
                                    <Button size="sm" variant="ghost" onClick={() => actions.reopenLesson(lesson.id)}><RotateCcw size={15} aria-hidden="true" /> Mark as not done</Button>
                                </>
                            ) : (
                                <>
                                    <p className="flex-1 text-sm text-muted">Finished reading and answering? Mark it done{data.cards.length ? `, and its ${data.cards.length} takeaways join your reviews` : ''}.</p>
                                    <Button variant="success" onClick={() => actions.completeLesson(lesson.id, data.cards)}><CheckCircle2 size={18} aria-hidden="true" /> Mark complete</Button>
                                </>
                            )}
                        </div>
                    </>
                )}

                <nav aria-label="Lessons" className="mt-8 grid gap-3 sm:grid-cols-2">
                    {previous ? (
                        <Link to={links.lesson(previous.id)} className="rounded-2xl border border-line p-4 hover:border-white/25">
                            <span className="flex items-center gap-1 font-mono text-xs text-muted"><ArrowLeft size={13} aria-hidden="true" /> Previous</span>
                            <span className="mt-1 block font-medium">{previous.title}</span>
                        </Link>
                    ) : <span />}
                    {next && (
                        <Link to={links.lesson(next.id)} className="rounded-2xl border border-line p-4 text-right hover:border-white/25">
                            <span className="flex items-center justify-end gap-1 font-mono text-xs text-muted">Next <ArrowRight size={13} aria-hidden="true" /></span>
                            <span className="mt-1 block font-medium">{next.title}</span>
                        </Link>
                    )}
                </nav>
            </article>

            <aside className="hidden xl:block">
                <div className="sticky top-24 space-y-6">
                    {content.status === 'ready' && <OnThisPage headings={data.headings} />}
                    {content.status === 'ready' && done && <ButtonLink to={next ? links.lesson(next.id) : links.path} size="sm" variant="primary">Next lesson <ArrowRight size={15} aria-hidden="true" /></ButtonLink>}
                </div>
            </aside>
        </div>
    );
};

const LessonPage = () => {
    const { lessonById } = useCourse();
    const { lessonId } = useParams();
    const lesson = lessonById[lessonId];
    if (!lesson) return <ConsoleNotFound />;
    return <LessonView key={lesson.id} lesson={lesson} />;
};

export default LessonPage;

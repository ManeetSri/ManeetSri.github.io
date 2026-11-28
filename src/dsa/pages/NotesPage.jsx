import { Link } from 'react-router-dom';
import { Bookmark, CircleAlert, Flag, NotebookPen } from 'lucide-react';
import { useCourse } from '../course/context.js';
import { mockMistakes, problemMistakes, quizMistakes } from '../engine/mistakes.js';
import { useStore } from '../store/store.js';
import { formatDate } from '../ui/format.js';
import { useConsoleMeta } from '../ui/hooks.js';
import { Card, EmptyState, PageHeader } from '../ui/primitives.jsx';

const LinkList = ({ items }) => (
    <ul className="space-y-1">
        {items.map((item) => (
            <li key={item.key ?? item.to}>
                <Link to={item.to} className="flex items-center justify-between gap-3 rounded-xl px-3 py-2 hover:bg-white/[0.04]">
                    <span className="min-w-0 truncate">{item.title}</span>
                    <span className="shrink-0 font-mono text-xs text-muted">{item.detail}</span>
                </Link>
            </li>
        ))}
    </ul>
);

const NotesPage = () => {
    const { lessonById, moduleById, practiceById: problemById, links } = useCourse();
    useConsoleMeta('Notes', links.notes);
    const { notes, lessons, problems, mocks } = useStore();

    const lessonNotes = Object.entries(notes)
        .filter(([id, note]) => lessonById[id] && note.text?.trim())
        .sort(([, a], [, b]) => b.updatedAt - a.updatedAt);
    const problemNotes = Object.entries(problems).filter(([id, record]) => problemById[id] && record.notes?.trim());
    const bookmarked = Object.entries(lessons).filter(([id, record]) => record.bookmarked && lessonById[id]).map(([id]) => lessonById[id]);
    const confusing = Object.entries(lessons).filter(([id, record]) => record.confusing && lessonById[id]).map(([id]) => lessonById[id]);
    const lessonLink = (lesson) => ({ to: links.lesson(lesson.id), title: lesson.title, detail: moduleById[lesson.module].code });
    const missedQuizzes = quizMistakes(lessons, lessonById);
    const shakyProblems = problemMistakes(problems, problemById);
    const roughMocks = mockMistakes(mocks ?? {});
    const mistakes = [
        ...shakyProblems.map((entry) => ({ to: links.item(entry.problemId), title: problemById[entry.problemId].title, detail: entry.reason })),
        ...roughMocks.map((mock) => ({ key: `mock-${mock.at}`, to: links.mock, title: `Mock: ${problemById[mock.problemId]?.title ?? mock.problemId}`, detail: `${mock.average.toFixed(1)} / 4${mock.weakest ? ` · weakest: ${mock.weakest}` : ''}` })),
        ...missedQuizzes.map((entry) => ({ to: links.lesson(entry.lessonId), title: lessonById[entry.lessonId].title, detail: `${entry.missed} missed first time${entry.stillWrong ? `, ${entry.stillWrong} still wrong` : ''}` })),
    ];
    const nothing = !lessonNotes.length && !problemNotes.length && !bookmarked.length && !confusing.length && !mistakes.length;

    return (
        <div className="mx-auto max-w-4xl">
            <PageHeader title="Notes & bookmarks">Everything you’ve written, saved or flagged, in one place.</PageHeader>
            {nothing && <EmptyState icon={NotebookPen} title="Nothing here yet">Write notes at the end of a lesson, bookmark lessons you want to revisit, and flag the ones that confused you.</EmptyState>}

            {mistakes.length > 0 && (
                <Card className="mb-6 p-4">
                    <h2 className="mb-1 flex items-center gap-2 px-3 font-semibold"><CircleAlert size={16} aria-hidden="true" className="text-[#FF9D96]" /> Mistakes log</h2>
                    <p className="mb-2 px-3 text-sm text-muted">Problems that aren’t solid yet, mocks that went badly and quiz questions you missed the first time. Go through it once a week.</p>
                    <LinkList items={mistakes} />
                </Card>
            )}

            <div className="grid gap-6 md:grid-cols-2">
                {bookmarked.length > 0 && (
                    <Card className="p-4">
                        <h2 className="mb-2 flex items-center gap-2 px-3 font-semibold"><Bookmark size={16} aria-hidden="true" className="text-amber" /> Bookmarked</h2>
                        <LinkList items={bookmarked.map(lessonLink)} />
                    </Card>
                )}
                {confusing.length > 0 && (
                    <Card className="p-4">
                        <h2 className="mb-2 flex items-center gap-2 px-3 font-semibold"><Flag size={16} aria-hidden="true" className="text-swift" /> Flagged as confusing</h2>
                        <LinkList items={confusing.map(lessonLink)} />
                    </Card>
                )}
            </div>

            {lessonNotes.length > 0 && (
                <section className="mt-8">
                    <h2 className="mb-3 font-display text-2xl font-semibold tracking-tight">Lesson notes</h2>
                    <ul className="space-y-3">
                        {lessonNotes.map(([id, note]) => (
                            <li key={id}>
                                <Card className="p-4">
                                    <Link to={links.lesson(id)} className="font-semibold hover:text-amber">{lessonById[id].title}</Link>
                                    <p className="mt-0.5 font-mono text-xs text-muted">{moduleById[lessonById[id].module].code} · {formatDate(note.updatedAt)}</p>
                                    <p className="mt-2 whitespace-pre-wrap text-sm leading-relaxed text-paper/85">{note.text}</p>
                                </Card>
                            </li>
                        ))}
                    </ul>
                </section>
            )}

            {problemNotes.length > 0 && (
                <section className="mt-8">
                    <h2 className="mb-3 font-display text-2xl font-semibold tracking-tight">Problem notes</h2>
                    <ul className="space-y-3">
                        {problemNotes.map(([id, record]) => (
                            <li key={id}>
                                <Card className="p-4">
                                    <Link to={links.item(id)} className="font-semibold hover:text-amber">{problemById[id].title}</Link>
                                    <p className="mt-2 whitespace-pre-wrap text-sm leading-relaxed text-paper/85">{record.notes}</p>
                                </Card>
                            </li>
                        ))}
                    </ul>
                </section>
            )}
        </div>
    );
};

export default NotesPage;

import { Link } from 'react-router-dom';
import { Bookmark, Flag, NotebookPen } from 'lucide-react';
import { lessonById, moduleById } from '../data/curriculum.js';
import { problemById } from '../data/problems.js';
import { useStore } from '../store/store.js';
import { formatDate } from '../ui/format.js';
import { useConsoleMeta } from '../ui/hooks.js';
import { Card, EmptyState, PageHeader } from '../ui/primitives.jsx';

const LinkList = ({ items }) => (
    <ul className="space-y-1">
        {items.map((item) => (
            <li key={item.to}>
                <Link to={item.to} className="flex items-center justify-between gap-3 rounded-xl px-3 py-2 hover:bg-white/[0.04]">
                    <span className="min-w-0 truncate">{item.title}</span>
                    <span className="shrink-0 font-mono text-xs text-muted">{item.detail}</span>
                </Link>
            </li>
        ))}
    </ul>
);

const NotesPage = () => {
    useConsoleMeta('Notes', '/dsa/notes');
    const { notes, lessons, problems } = useStore();

    const lessonNotes = Object.entries(notes)
        .filter(([id, note]) => lessonById[id] && note.text?.trim())
        .sort(([, a], [, b]) => b.updatedAt - a.updatedAt);
    const problemNotes = Object.entries(problems).filter(([id, record]) => problemById[id] && record.notes?.trim());
    const bookmarked = Object.entries(lessons).filter(([id, record]) => record.bookmarked && lessonById[id]).map(([id]) => lessonById[id]);
    const confusing = Object.entries(lessons).filter(([id, record]) => record.confusing && lessonById[id]).map(([id]) => lessonById[id]);
    const lessonLink = (lesson) => ({ to: `/dsa/learn/${lesson.id}`, title: lesson.title, detail: moduleById[lesson.module].code });
    const nothing = !lessonNotes.length && !problemNotes.length && !bookmarked.length && !confusing.length;

    return (
        <div className="mx-auto max-w-4xl">
            <PageHeader title="Notes & bookmarks">Everything you’ve written, saved or flagged, in one place.</PageHeader>
            {nothing && <EmptyState icon={NotebookPen} title="Nothing here yet">Write notes at the end of a lesson, bookmark lessons you want to revisit, and flag the ones that confused you.</EmptyState>}

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
                                    <Link to={`/dsa/learn/${id}`} className="font-semibold hover:text-amber">{lessonById[id].title}</Link>
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
                                    <Link to={`/dsa/practice/${id}`} className="font-semibold hover:text-amber">{problemById[id].title}</Link>
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

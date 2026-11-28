import { NavLink, useParams } from 'react-router-dom';
import { LoaderCircle } from 'lucide-react';
import { useContent } from '../content/index.js';
import { useCourse } from '../course/context.js';
import { mdxComponents } from '../mdx/components.js';
import { useConsoleMeta } from '../ui/hooks.js';
import { EmptyState, PageHeader } from '../ui/primitives.jsx';

// Each course lists its sheets in course.sheets
const SheetsPage = () => {
    const { sheets: SHEETS, links } = useCourse();
    const { sheetId = SHEETS[0].id } = useParams();
    const sheet = SHEETS.find((item) => item.id === sheetId) ?? SHEETS[0];
    useConsoleMeta(sheet.title, links.sheet(sheet.id));
    const content = useContent('sheet', sheet.id);
    const { Content } = content;

    return (
        <div className="mx-auto max-w-5xl">
            <PageHeader eyebrow="Cheat sheets" title={sheet.title}>{sheet.detail}</PageHeader>
            <nav aria-label="Cheat sheets" className="-mx-1 mb-8 flex gap-1 overflow-x-auto pb-1">
                {SHEETS.map((item) => (
                    <NavLink
                        key={item.id}
                        to={links.sheet(item.id)}
                        className={() => `shrink-0 rounded-full px-4 py-2 text-sm ${item.id === sheet.id ? 'bg-white/12 font-medium text-paper' : 'text-muted hover:bg-white/[0.06] hover:text-paper'}`}
                        aria-current={item.id === sheet.id ? 'page' : undefined}
                    >
                        {item.title}
                    </NavLink>
                ))}
            </nav>
            <article className="max-w-4xl">
                {content.status === 'loading' && <p className="flex items-center gap-2 text-muted" role="status"><LoaderCircle size={18} aria-hidden="true" className="animate-spin" /> Loading…</p>}
                {content.status === 'missing' && <EmptyState title="This sheet is coming soon" />}
                {content.status === 'error' && <EmptyState title="The sheet didn’t load">Check your connection and try again.</EmptyState>}
                {content.status === 'ready' && <Content components={mdxComponents} />}
            </article>
        </div>
    );
};

export default SheetsPage;

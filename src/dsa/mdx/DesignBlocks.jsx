import { AlertTriangle, ClipboardList, FileText } from 'lucide-react';
import { useDesignAnswer } from './designContext.js';

// <Brief>: the scenario of a design exercise or the code under review. Always shown.
export const Brief = ({ children }) => (
    <section aria-label="The brief" className="my-6 rounded-2xl border border-line bg-surface p-4 sm:p-5">
        <p className="mb-2 flex items-center gap-2 font-mono text-xs uppercase tracking-wider text-muted"><FileText size={14} aria-hidden="true" /> The brief</p>
        <div className="[&>p:first-child]:mt-0 [&>p:last-child]:mb-0">{children}</div>
    </section>
);

// <ModelAnswer section="…">: hidden while you write; afterwards it sits beside your answer for that section
export const ModelAnswer = ({ section, children }) => {
    const { revealed, answers, sections } = useDesignAnswer();
    if (!revealed) return null;
    const title = sections.find((item) => item.id === section)?.title ?? section;
    const yours = answers[section]?.trim();
    return (
        <section aria-label={`${title}: your answer and the model answer`} className="my-6 rounded-2xl border border-line">
            <h3 className="border-b border-line px-4 py-2.5 font-display text-lg font-semibold">{title}</h3>
            <div className="grid gap-px bg-line md:grid-cols-2">
                <div className="bg-ink p-4">
                    <p className="mb-2 font-mono text-[11px] uppercase tracking-wider text-muted">Your answer</p>
                    {yours ? <p className="whitespace-pre-wrap text-sm leading-relaxed text-paper/85">{yours}</p> : <p className="text-sm text-muted">You left this section empty.</p>}
                </div>
                <div className="bg-surface p-4 text-[15px] [&>p:first-child]:mt-0 [&>ul:first-child]:mt-0">
                    <p className="mb-2 font-mono text-[11px] uppercase tracking-wider text-[#9FE6B0]">Model answer</p>
                    {children}
                </div>
            </div>
        </section>
    );
};

// <Pitfalls>: the usual mistakes, shown once the answer is revealed
export const Pitfalls = ({ children }) => {
    const { revealed } = useDesignAnswer();
    if (!revealed) return null;
    return (
        <aside className="my-6 rounded-2xl border-y border-l-4 border-r border-amber/50 bg-amber/[0.07] p-4 sm:p-5">
            <p className="mb-1 flex items-center gap-2 font-semibold"><AlertTriangle size={17} aria-hidden="true" className="text-amber" /> Common mistakes</p>
            <div className="text-paper/85 [&>p]:my-2 [&>ul]:my-2">{children}</div>
        </aside>
    );
};

// <ReferenceReview>: how an experienced reviewer would write it up, shown once the answer is revealed
export const ReferenceReview = ({ children }) => {
    const { revealed } = useDesignAnswer();
    if (!revealed) return null;
    return (
        <section aria-label="Reference review" className="my-6 rounded-2xl border border-[#30D158]/30 bg-[#30D158]/[0.04] p-4 sm:p-5">
            <p className="mb-2 flex items-center gap-2 font-semibold"><ClipboardList size={17} aria-hidden="true" className="text-[#30D158]" /> Reference review</p>
            <div className="[&>p:last-child]:mb-0">{children}</div>
        </section>
    );
};

import { Children, isValidElement } from 'react';
import { AlertTriangle, ChevronRight, Info, Lightbulb, Repeat, Sparkles, Zap } from 'lucide-react';
import { Inline } from './inline.jsx';

const CALLOUTS = {
    note: { icon: Info, label: 'Note', className: 'border-sky-400/40 bg-sky-400/[0.06]', iconClass: 'text-sky-300' },
    tip: { icon: Lightbulb, label: 'Tip', className: 'border-[#30D158]/40 bg-[#30D158]/[0.06]', iconClass: 'text-[#30D158]' },
    gotcha: { icon: Zap, label: 'Swift gotcha', className: 'border-swift/50 bg-swift/[0.07]', iconClass: 'text-swift' },
    warning: { icon: AlertTriangle, label: 'Watch out', className: 'border-amber/50 bg-amber/[0.07]', iconClass: 'text-amber' },
    analogy: { icon: Sparkles, label: 'Analogy', className: 'border-violet-400/40 bg-violet-400/[0.06]', iconClass: 'text-violet-300' },
};

// <Callout kind="gotcha" title="…">markdown</Callout>
export const Callout = ({ kind = 'note', title, children }) => {
    const style = CALLOUTS[kind] ?? CALLOUTS.note;
    const Icon = style.icon;
    return (
        <aside className={`my-6 rounded-2xl border-l-4 border-y border-r p-4 sm:p-5 ${style.className}`}>
            <p className="mb-1 flex items-center gap-2 font-semibold">
                <Icon size={17} aria-hidden="true" className={style.iconClass} /> {title ?? style.label}
            </p>
            <div className="text-paper/85 [&>p]:my-2 [&>p:last-child]:mb-0 [&>ul]:my-2">{children}</div>
        </aside>
    );
};

// A ```cards block: the lesson's key takeaways, which become review cards once the lesson is finished
export const Takeaways = ({ data }) => {
    const { cards } = JSON.parse(data);
    return (
        <section aria-labelledby="takeaways" className="my-8 rounded-2xl border border-line bg-surface p-5">
            <h2 id="takeaways" className="mb-1 flex items-center gap-2 font-display text-xl font-semibold"><Repeat size={18} aria-hidden="true" className="text-amber" /> Key takeaways</h2>
            <p className="mb-4 text-sm text-muted">These become review cards when you finish the lesson.</p>
            <dl className="space-y-3">
                {cards.map((card) => (
                    <div key={card.id} className="rounded-xl bg-white/[0.04] p-3.5">
                        <dt className="font-semibold"><Inline text={card.front} /></dt>
                        <dd className="mt-1 text-sm leading-relaxed text-paper/80"><Inline text={card.back} /></dd>
                    </div>
                ))}
            </dl>
        </section>
    );
};

// <Hints><Hint>…</Hint><Hint>…</Hint></Hints>: each one opens separately, so you only take what you need
export const Hint = ({ children }) => children;

export const Hints = ({ children }) => {
    const hints = Children.toArray(children).filter(isValidElement);
    return (
        <div className="my-6 space-y-2">
            {hints.map((hint, index) => (
                <details key={index} className="group rounded-xl border border-line bg-surface">
                    <summary className="flex min-h-12 cursor-pointer list-none items-center gap-2 px-4 font-medium [&::-webkit-details-marker]:hidden">
                        <ChevronRight size={16} aria-hidden="true" className="shrink-0 text-amber transition-transform group-open:rotate-90" />
                        Hint {index + 1} of {hints.length}
                    </summary>
                    <div className="px-4 pb-4 text-paper/85 [&>p]:my-2">{hint.props.children}</div>
                </details>
            ))}
        </div>
    );
};

// <Approach title="Brute force" time="O(n²)" space="O(1)">explanation and code</Approach>, closed until opened
export const Approach = ({ title, time, space, children }) => (
    <details className="group my-4 rounded-2xl border border-line bg-surface">
        <summary className="flex min-h-14 cursor-pointer list-none flex-wrap items-center gap-x-3 gap-y-1 px-4 py-3 [&::-webkit-details-marker]:hidden">
            <ChevronRight size={16} aria-hidden="true" className="shrink-0 text-amber transition-transform group-open:rotate-90" />
            <span className="font-semibold">{title}</span>
            <span className="ml-auto flex gap-2 font-mono text-xs text-muted">
                {time && <span>Time {time}</span>}
                {space && <span>Space {space}</span>}
            </span>
        </summary>
        <div className="border-t border-line px-4 pb-2 sm:px-5">{children}</div>
    </details>
);

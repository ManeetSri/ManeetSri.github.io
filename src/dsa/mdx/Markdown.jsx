import { Link } from 'react-router-dom';
import { slugify } from './slug.js';

// How plain markdown looks in lessons and problems
export const H2 = ({ children }) => <h2 id={slugify(children)} className="mb-3 mt-12 scroll-mt-20 font-display text-[1.75rem] font-semibold leading-tight tracking-tight">{children}</h2>;
export const H3 = ({ children }) => <h3 id={slugify(children)} className="mb-2 mt-8 scroll-mt-20 text-xl font-semibold">{children}</h3>;
export const Paragraph = ({ children }) => <p className="my-4 leading-[1.75] text-paper/90">{children}</p>;
export const List = ({ children }) => <ul className="my-4 list-disc space-y-2 pl-6 leading-relaxed text-paper/90 marker:text-muted">{children}</ul>;
export const OrderedList = ({ children }) => <ol className="my-4 list-decimal space-y-2 pl-6 leading-relaxed text-paper/90 marker:font-mono marker:text-sm marker:text-muted">{children}</ol>;
export const ListItem = ({ children }) => <li className="pl-1">{children}</li>;
export const Strong = ({ children }) => <strong className="font-semibold text-paper">{children}</strong>;
export const InlineCode = ({ children }) => <code className="rounded-md bg-white/8 px-1.5 py-0.5 font-mono text-[0.88em] text-amber">{children}</code>;
export const Quote = ({ children }) => <blockquote className="my-6 border-l-2 border-amber pl-4 italic text-paper/80">{children}</blockquote>;
export const Rule = () => <hr className="my-10 border-line" />;

// Links inside the console stay in the app; anything else opens in a new tab
export const Anchor = ({ href = '', children }) => {
    const className = 'text-amber underline decoration-amber/40 underline-offset-2 hover:decoration-amber';
    if (href.startsWith('/dsa')) return <Link to={href} className={className}>{children}</Link>;
    return <a href={href} target="_blank" rel="noopener noreferrer" className={className}>{children}</a>;
};

export const Table = ({ children }) => (
    <div className="my-6 overflow-x-auto rounded-2xl border border-line">
        <table className="w-full border-collapse text-left text-sm">{children}</table>
    </div>
);
export const TableHead = ({ children }) => <thead className="bg-white/[0.04] font-mono text-xs uppercase tracking-wider text-muted">{children}</thead>;
export const HeaderCell = ({ children, style }) => <th className="whitespace-nowrap px-4 py-2.5 font-medium" style={style}>{children}</th>;
export const Cell = ({ children, style }) => <td className="border-t border-line px-4 py-2.5 align-top" style={style}>{children}</td>;

import { useState } from 'react';
import { Highlight } from 'prism-react-renderer';
import { Check, Copy, Play, TerminalSquare } from 'lucide-react';
import { xcodeTheme } from './prismTheme.js';

const LANGUAGE_LABELS = { swift: 'Swift', bash: 'Terminal', sh: 'Terminal', text: 'Text', json: 'JSON', js: 'JavaScript' };

export const CopyButton = ({ text, label = 'Copy', className = '' }) => {
    const [copied, setCopied] = useState(false);
    const copy = async () => {
        try {
            await navigator.clipboard.writeText(text);
            setCopied(true);
            setTimeout(() => setCopied(false), 1600);
        } catch {
            // Clipboard access was refused
        }
    };
    return (
        <button type="button" onClick={copy} className={`inline-flex h-8 items-center gap-1.5 rounded-full px-2.5 text-xs text-muted hover:bg-white/8 hover:text-paper ${className}`}>
            {copied ? <Check size={14} aria-hidden="true" className="text-[#30D158]" /> : <Copy size={14} aria-hidden="true" />}
            <span>{copied ? 'Copied' : label}</span>
            <span className="sr-only" role="status">{copied ? 'Copied to the clipboard' : ''}</span>
        </button>
    );
};

export const HighlightedCode = ({ code, lang = 'swift', highlight = [], activeLine = null, showNumbers = true }) => (
    <Highlight theme={xcodeTheme} code={code.replace(/\n$/, '')} language={lang}>
        {({ tokens, getLineProps, getTokenProps }) => (
            <pre className="overflow-x-auto py-3 font-mono text-[13px] leading-6">
                <code className="block min-w-max">
                    {tokens.map((line, index) => {
                        const number = index + 1;
                        const lineProps = getLineProps({ line });
                        const marked = highlight.includes(number);
                        const active = activeLine === number;
                        return (
                            <span
                                key={number}
                                {...lineProps}
                                className={`flex pr-4 ${active ? 'bg-amber/15 shadow-[inset_3px_0_0_var(--color-amber)]' : marked ? 'bg-white/[0.06]' : ''}`}
                                aria-current={active ? 'step' : undefined}
                            >
                                {showNumbers && <span aria-hidden="true" className="w-10 shrink-0 select-none pr-3 text-right text-white/25">{number}</span>}
                                <span className={showNumbers ? '' : 'pl-4'}>
                                    {line.map((token, key) => <span key={key} {...getTokenProps({ token })} />)}
                                    {line.length === 1 && line[0].empty ? '\n' : null}
                                </span>
                            </span>
                        );
                    })}
                </code>
            </pre>
        )}
    </Highlight>
);

// A fenced block from a lesson: ```swift title="…" highlight=2,4-5 run, optionally followed by an
// ```output block, which the build attaches as `output`. `run` is the example's file in dsa-swift.
const CodeBlock = ({ data, ...direct }) => {
    const { lang = 'swift', code, title, run, highlight = [], output } = data ? JSON.parse(data) : direct;
    const isTerminal = lang === 'bash' || lang === 'sh';
    return (
        <figure className="my-6 overflow-hidden rounded-2xl border border-line bg-[#101217]">
            <figcaption className="flex items-center gap-2 border-b border-line py-1 pl-4 pr-1.5">
                {isTerminal && <TerminalSquare size={14} aria-hidden="true" className="text-muted" />}
                <span className="min-w-0 flex-1 truncate font-mono text-xs text-muted">{title ?? LANGUAGE_LABELS[lang] ?? lang}</span>
                {/* Run from the dsa-swift folder: every runnable example is also a file there */}
                {run && <CopyButton text={`swift ${run}`} label="Run command" />}
                <CopyButton text={code} />
            </figcaption>
            <HighlightedCode code={code} lang={lang} highlight={highlight} showNumbers={!isTerminal && code.split('\n').length > 3} />
            {output !== undefined && (
                <div className="border-t border-line bg-black/30">
                    <p className="flex items-center gap-1.5 px-4 pt-2.5 font-mono text-[11px] uppercase tracking-wider text-muted">
                        <Play size={11} aria-hidden="true" /> Output
                    </p>
                    <pre className="overflow-x-auto px-4 pb-3 pt-1 font-mono text-[13px] leading-6 text-[#9FE6B0]">{output.replace(/\n$/, '')}</pre>
                </div>
            )}
        </figure>
    );
};

export default CodeBlock;

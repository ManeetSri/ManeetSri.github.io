import { useRef } from 'react';
import { Highlight } from 'prism-react-renderer';
import { xcodeTheme } from '../mdx/prismTheme.js';

// A Swift editor: a transparent textarea over the same code highlighted, so typing is the browser's own
// (undo, selection, mobile keyboards) and the colours come from Prism. It needs no style injection, which
// keeps the site's Content Security Policy strict. Both layers share one font, size, line height and padding.

const INDENT = '    ';
const LINE = 24;                // leading-6
const PAD = 12;                 // py-3
const OPENERS = { '{': '}', '(': ')', '[': ']' };

// Bold and italic tokens could shift glyphs by a hair, and the caret must sit exactly over the text
const flat = ({ fontWeight: _weight, fontStyle: _slant, ...style } = {}) => style;

// execCommand keeps the edit in the browser's undo history; setRangeText is the fallback where it's missing
const insert = (textarea, text, from, to) => {
    textarea.setSelectionRange(from, to);
    if (!document.execCommand?.('insertText', false, text)) {
        textarea.setRangeText(text, from, to, 'end');
        textarea.dispatchEvent(new Event('input', { bubbles: true }));
    }
};

const lineStartOf = (value, index) => value.lastIndexOf('\n', index - 1) + 1;

export const CodeEditor = ({ value, onChange, onSave, label, readOnly = false }) => {
    const scroller = useRef(null);
    const releaseTab = useRef(false);

    // Keep the caret's line in view when typing or moving past the visible part
    const reveal = (textarea) => requestAnimationFrame(() => {
        const box = scroller.current;
        if (!box) return;
        const top = PAD + (textarea.value.slice(0, textarea.selectionEnd).split('\n').length - 1) * LINE;
        if (top < box.scrollTop) box.scrollTop = top - PAD;
        else if (top + LINE > box.scrollTop + box.clientHeight) box.scrollTop = top + LINE + PAD - box.clientHeight;
    });

    const keyDown = (event) => {
        const textarea = event.currentTarget;
        const { value: text, selectionStart: start, selectionEnd: end } = textarea;
        // Esc, then Tab, moves focus on instead of indenting, so the keyboard is never trapped here
        if (event.key === 'Escape') {
            releaseTab.current = true;
            return;
        }
        if (event.key === 'Tab' && releaseTab.current) {
            releaseTab.current = false;
            return;
        }
        releaseTab.current = false;
        if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 's') {
            event.preventDefault();
            onSave?.();
            return;
        }
        if (readOnly || event.nativeEvent.isComposing) return;

        if (event.key === 'Tab') {
            event.preventDefault();
            if (start === end && !event.shiftKey) {
                insert(textarea, INDENT, start, end);
                return;
            }
            // Indent or outdent every line the selection touches
            const from = lineStartOf(text, start);
            const last = end > start && text[end - 1] === '\n' ? end - 1 : end;
            const stop = text.indexOf('\n', last) === -1 ? text.length : text.indexOf('\n', last);
            const lines = text.slice(from, stop).split('\n');
            const changed = lines.map((line) => (event.shiftKey ? line.replace(/^ {1,4}/, '') : INDENT + line));
            const block = changed.join('\n');
            insert(textarea, block, from, stop);
            textarea.setSelectionRange(Math.max(from, start + changed[0].length - lines[0].length), end + block.length - (stop - from));
            return;
        }

        if (event.key === 'Enter' && !event.metaKey && !event.ctrlKey && !event.altKey) {
            event.preventDefault();
            const indent = text.slice(lineStartOf(text, start), start).match(/^ */)[0];
            const closer = OPENERS[text[start - 1]];
            if (!closer) {
                insert(textarea, `\n${indent}`, start, end);
            } else if (text[end] === closer) {
                // Between a pair, the closer moves to its own line and the caret goes inside
                insert(textarea, `\n${indent}${INDENT}\n${indent}`, start, end);
                const caret = start + 1 + indent.length + INDENT.length;
                textarea.setSelectionRange(caret, caret);
            } else {
                insert(textarea, `\n${indent}${INDENT}`, start, end);
            }
            reveal(textarea);
            return;
        }

        const beforeCaret = text.slice(lineStartOf(text, start), start);
        // A closing brace on a blank line steps back one level
        if (event.key === '}' && start === end && beforeCaret.length >= INDENT.length && /^ +$/.test(beforeCaret)) {
            event.preventDefault();
            insert(textarea, '}', start - INDENT.length, end);
            return;
        }
        // Backspace in the indentation removes a whole level
        if (event.key === 'Backspace' && start === end && beforeCaret.length > 0 && /^ +$/.test(beforeCaret)) {
            event.preventDefault();
            insert(textarea, '', start - (((beforeCaret.length - 1) % INDENT.length) + 1), end);
        }
    };

    return (
        <div ref={scroller} className="max-h-[min(70svh,42rem)] overflow-auto rounded-xl border border-line bg-[#101217] focus-within:border-amber">
            <Highlight theme={xcodeTheme} code={value} language="swift">
                {({ tokens, getTokenProps }) => (
                    <div className="flex min-w-max font-mono text-base leading-6 [font-variant-ligatures:none] [tab-size:4] sm:text-[13px]">
                        <div aria-hidden="true" className="sticky left-0 z-10 select-none bg-[#101217] py-3 pl-3 pr-3 text-right text-white/25">
                            {tokens.map((_, index) => <div key={index} className="min-h-6">{index + 1}</div>)}
                        </div>
                        <div className="relative flex-1">
                            <pre aria-hidden="true" className="m-0 whitespace-pre py-3 pl-1 pr-8 font-mono">
                                {tokens.map((line, index) => (
                                    <div key={index} className="min-h-6">
                                        {line.map((token, key) => {
                                            const props = getTokenProps({ token });
                                            return <span key={key} {...props} style={flat(props.style)} />;
                                        })}
                                    </div>
                                ))}
                            </pre>
                            <textarea
                                value={value}
                                onChange={(event) => onChange(event.target.value)}
                                onKeyDown={keyDown}
                                onSelect={(event) => reveal(event.currentTarget)}
                                readOnly={readOnly}
                                aria-label={label}
                                spellCheck={false}
                                autoCapitalize="off"
                                autoComplete="off"
                                autoCorrect="off"
                                translate="no"
                                wrap="off"
                                className="absolute inset-0 h-full w-full resize-none overflow-hidden whitespace-pre bg-transparent py-3 pl-1 pr-8 font-mono text-transparent caret-[#F2F0EB] outline-none selection:bg-sky-400/30"
                            />
                        </div>
                    </div>
                )}
            </Highlight>
        </div>
    );
};

import { useId, useMemo, useState } from 'react';
import { ArrowDown, ArrowUp, Check, CircleCheck, CircleX, Eye, RotateCcw } from 'lucide-react';
import { HighlightedCode } from '../CodeBlock.jsx';
import { Inline } from '../inline.jsx';
import { Button } from '../../ui/primitives.jsx';
import { BIG_O_OPTIONS, correctAnswerText, emptyAnswer, estimateRange, isAnswered, isCorrect, shuffledIndexes, TYPE_LABELS } from './grading.js';

const optionTone = (checked, isRight, chosen) => {
    if (!checked) return chosen ? 'border-amber bg-amber/10' : 'border-line hover:border-white/30';
    if (isRight) return 'border-[#30D158] bg-[#30D158]/10';
    return chosen ? 'border-[#FF9D96] bg-[#FF9D96]/10' : 'border-line opacity-70';
};

// Radio buttons or checkboxes, used by multiple choice, multi-select, true/false and Big-O
const Choices = ({ name, options, value, onChange, multiple, checked, isRight, mono }) => (
    <div role={multiple ? 'group' : 'radiogroup'} className="grid gap-2">
        {options.map((option, index) => {
            const chosen = multiple ? value.includes(index) : value === index;
            return (
                <label key={index} className={`flex cursor-pointer items-start gap-3 rounded-xl border px-4 py-3 transition-colors ${optionTone(checked, isRight(index), chosen)} ${checked ? 'cursor-default' : ''}`}>
                    <input
                        type={multiple ? 'checkbox' : 'radio'}
                        name={name}
                        checked={chosen}
                        disabled={checked}
                        onChange={() => onChange(multiple ? (chosen ? value.filter((item) => item !== index) : [...value, index]) : index)}
                        className="mt-1 h-4 w-4 shrink-0 accent-[var(--color-amber)]"
                    />
                    <span className={mono ? 'font-mono text-sm' : ''}><Inline text={option} /></span>
                </label>
            );
        })}
    </div>
);

const CodeView = ({ code }) => (
    <div className="overflow-hidden rounded-xl border border-line bg-[#101217]">
        <HighlightedCode code={code} showNumbers={code.split('\n').length > 2} />
    </div>
);

const BlankCode = ({ code, answer, onChange, checked, question }) => {
    const parts = code.replace(/\n$/, '').split(/(___)/);
    return (
        <pre className="overflow-x-auto rounded-xl border border-line bg-[#101217] p-4 font-mono text-[13px] leading-8">
            {parts.map((part, index) => {
                if (part !== '___') return <span key={index}>{part}</span>;
                const position = parts.slice(0, index).filter((earlier) => earlier === '___').length;
                const expected = [question.answers[position]].flat();
                const right = checked && expected.some((value) => value.trim() === answer[position].trim());
                return (
                    <input
                        key={index}
                        value={answer[position]}
                        disabled={checked}
                        onChange={(event) => onChange(answer.map((value, at) => (at === position ? event.target.value : value)))}
                        aria-label={`Blank ${position + 1}`}
                        autoCapitalize="off"
                        autoCorrect="off"
                        spellCheck={false}
                        style={{ width: `${Math.max(4, ...expected.map((value) => value.length)) + 2}ch` }}
                        className={`mx-0.5 rounded-md border bg-white/5 px-1.5 text-center text-amber outline-none focus:border-amber ${checked ? (right ? 'border-[#30D158]' : 'border-[#FF9D96]') : 'border-white/20'}`}
                    />
                );
            })}
        </pre>
    );
};

const OrderLines = ({ lines, answer, onChange, checked }) => {
    const move = (from, to) => {
        const next = [...answer];
        [next[from], next[to]] = [next[to], next[from]];
        onChange(next);
    };
    return (
        <ol className="space-y-1.5">
            {answer.map((lineIndex, position) => {
                const right = lineIndex === position;
                return (
                    <li key={lineIndex} className={`flex items-center gap-2 rounded-xl border bg-[#101217] py-1 pl-3 pr-1 ${checked ? (right ? 'border-[#30D158]' : 'border-[#FF9D96]') : 'border-line'}`}>
                        <span aria-hidden="true" className="w-5 shrink-0 font-mono text-xs text-muted">{position + 1}</span>
                        <code className="min-w-0 flex-1 overflow-x-auto whitespace-pre font-mono text-[13px]">{lines[lineIndex]}</code>
                        {!checked && (
                            <span className="flex shrink-0">
                                <button type="button" disabled={position === 0} onClick={() => move(position, position - 1)} aria-label={`Move “${lines[lineIndex].trim()}” up`} className="flex h-9 w-9 items-center justify-center rounded-full text-muted hover:bg-white/8 hover:text-paper disabled:opacity-25">
                                    <ArrowUp size={16} aria-hidden="true" />
                                </button>
                                <button type="button" disabled={position === answer.length - 1} onClick={() => move(position, position + 1)} aria-label={`Move “${lines[lineIndex].trim()}” down`} className="flex h-9 w-9 items-center justify-center rounded-full text-muted hover:bg-white/8 hover:text-paper disabled:opacity-25">
                                    <ArrowDown size={16} aria-hidden="true" />
                                </button>
                            </span>
                        )}
                    </li>
                );
            })}
        </ol>
    );
};

const BugLines = ({ name, code, value, onChange, checked, answerLine }) => (
    <div role="radiogroup" className="overflow-x-auto rounded-xl border border-line bg-[#101217] py-2">
        {code.replace(/\n$/, '').split('\n').map((line, index) => {
            const number = index + 1;
            const chosen = value === number;
            const tone = checked && number === answerLine ? 'bg-[#30D158]/15' : chosen ? (checked ? 'bg-[#FF9D96]/15' : 'bg-amber/15') : 'hover:bg-white/5';
            return (
                <label key={number} className={`flex min-w-max cursor-pointer items-center gap-3 px-3 font-mono text-[13px] leading-7 ${tone}`}>
                    <input type="radio" name={name} checked={chosen} disabled={checked} onChange={() => onChange(number)} className="sr-only peer" />
                    <span aria-hidden="true" className="w-6 text-right text-white/30 peer-focus-visible:text-amber">{number}</span>
                    <span className="whitespace-pre">{line || ' '}</span>
                </label>
            );
        })}
    </div>
);

const MatchPairs = ({ question, answer, onChange, checked }) => {
    const rightOrder = useMemo(() => shuffledIndexes(question.pairs.length, `${question.id}-match`), [question]);
    return (
        <div className="space-y-2">
            {question.pairs.map(([left], index) => {
                const right = answer[index] === index;
                return (
                    <div key={left} className={`grid items-center gap-2 rounded-xl border p-2 pl-4 sm:grid-cols-2 ${checked ? (right ? 'border-[#30D158]' : 'border-[#FF9D96]') : 'border-line'}`}>
                        <span><Inline text={left} /></span>
                        <select
                            value={answer[index]}
                            disabled={checked}
                            onChange={(event) => onChange(answer.map((value, at) => (at === index ? Number(event.target.value) : value)))}
                            aria-label={`Match for ${left}`}
                            className="h-10 w-full rounded-lg border border-line bg-raised px-3 text-sm outline-none focus:border-amber"
                        >
                            <option value={-1}>Choose…</option>
                            {rightOrder.map((pairIndex) => <option key={pairIndex} value={pairIndex}>{question.pairs[pairIndex][1]}</option>)}
                        </select>
                    </div>
                );
            })}
        </div>
    );
};

// A number, written however you like (2.5k, 3M, 1,200), with how close it has to be
const Estimate = ({ question, answer, onChange, checked }) => {
    const { within = {} } = question;
    const tolerance = within.percent !== undefined ? `within ${within.percent}%` : `within a factor of ${within.factor ?? 2}`;
    return (
        <div>
            <label className="flex flex-wrap items-center gap-3">
                <input
                    value={answer}
                    onChange={(event) => onChange(event.target.value)}
                    disabled={checked}
                    inputMode="decimal"
                    autoComplete="off"
                    aria-label={`Your estimate${question.unit ? ` in ${question.unit}` : ''}`}
                    placeholder="e.g. 2.5k"
                    className="h-11 w-48 rounded-xl border border-line bg-[#101217] px-3 font-mono text-[15px] outline-none focus:border-amber"
                />
                {question.unit && <span className="text-muted">{question.unit}</span>}
            </label>
            <p className="mt-2 text-xs text-muted">Counts if it’s {tolerance} of the answer{checked ? ` (${estimateRange(question).map((value) => Number(value.toPrecision(3)).toLocaleString('en-GB')).join(' to ')})` : ''}.</p>
        </div>
    );
};

// Each item goes in one bucket. Items appear in a fixed shuffled order.
const SortItems = ({ question, answer, onChange, checked }) => {
    const order = useMemo(() => shuffledIndexes(question.items.length, `${question.id}-sort`), [question]);
    return (
        <div className="space-y-2">
            {order.map((index) => {
                const [text, bucket] = question.items[index];
                const right = answer[index] === bucket;
                return (
                    <div key={text} className={`grid items-center gap-2 rounded-xl border p-2 pl-4 sm:grid-cols-2 ${checked ? (right ? 'border-[#30D158]' : 'border-[#FF9D96]') : 'border-line'}`}>
                        <span><Inline text={text} /></span>
                        <select
                            value={answer[index]}
                            disabled={checked}
                            onChange={(event) => onChange(answer.map((value, at) => (at === index ? Number(event.target.value) : value)))}
                            aria-label={`Group for ${text}`}
                            className="h-10 w-full rounded-lg border border-line bg-raised px-3 text-sm outline-none focus:border-amber"
                        >
                            <option value={-1}>Choose…</option>
                            {question.buckets.map((name, at) => <option key={name} value={at}>{name}</option>)}
                        </select>
                    </div>
                );
            })}
        </div>
    );
};

const Recall = ({ question, answer, onChange, checked }) => {
    const [draft, setDraft] = useState('');
    const [revealed, setRevealed] = useState(false);
    return (
        <div className="space-y-3">
            <textarea
                value={draft}
                onChange={(event) => setDraft(event.target.value)}
                rows={3}
                aria-label="Your explanation"
                placeholder="Explain it in your own words first…"
                className="w-full rounded-xl border border-line bg-white/5 p-3 text-sm leading-relaxed outline-none focus:border-amber"
            />
            {!revealed ? (
                <Button size="sm" onClick={() => setRevealed(true)}><Eye size={16} aria-hidden="true" /> Show the model answer</Button>
            ) : (
                <>
                    <div className="rounded-xl border border-line bg-white/5 p-4 text-sm leading-relaxed">
                        <p className="mb-1 font-mono text-[11px] uppercase tracking-wider text-muted">Model answer</p>
                        <Inline text={question.model} />
                    </div>
                    {!checked && (
                        <div className="flex flex-wrap gap-2" role="group" aria-label="How did you do?">
                            <Button size="sm" variant={answer === true ? 'success' : 'secondary'} onClick={() => onChange(true)}>I had it</Button>
                            <Button size="sm" variant={answer === false ? 'primary' : 'secondary'} onClick={() => onChange(false)}>Not quite</Button>
                        </div>
                    )}
                </>
            )}
        </div>
    );
};

// One question: answer it, check it, see why. `onResult(correct)` fires on every check.
// `allowRetry` is off in the placement check, where the first answer is the one that counts.
const Question = ({ question, number, previous, onResult, allowRetry = true }) => {
    const name = useId();
    const [answer, setAnswer] = useState(() => emptyAnswer(question));
    const [result, setResult] = useState(null);
    const checked = result !== null;

    const check = () => {
        const correct = isCorrect(question, answer);
        setResult(correct);
        onResult?.(correct);
    };

    const retry = () => {
        setAnswer(emptyAnswer(question));
        setResult(null);
    };

    const choiceProps = { name, value: answer, onChange: setAnswer, checked };
    const rightAnswer = correctAnswerText(question);
    const isRecall = question.type === 'recall';

    return (
        <fieldset className="min-w-0 rounded-2xl border border-line bg-surface p-4 sm:p-5">
            <legend className="sr-only">Question {number}</legend>
            <div className="mb-3 flex flex-wrap items-center gap-2 font-mono text-xs text-muted">
                {number !== undefined && <span>Q{number}</span>}
                <span>·</span>
                <span>{TYPE_LABELS[question.type]}</span>
                {previous?.correct && <span className="ml-auto inline-flex items-center gap-1 text-[#30D158]"><Check size={13} aria-hidden="true" /> Answered before</span>}
            </div>
            <p className="mb-4 text-[17px] leading-relaxed"><Inline text={question.prompt} /></p>

            <div className="space-y-4">
                {question.code && !['blank', 'bug'].includes(question.type) && <CodeView code={question.code} />}

                {question.type === 'mcq' && <Choices {...choiceProps} options={question.options} isRight={(index) => index === question.answer} />}
                {question.type === 'multi' && <Choices {...choiceProps} multiple options={question.options} isRight={(index) => question.answer.includes(index)} />}
                {question.type === 'truefalse' && (
                    <Choices {...choiceProps} options={['True', 'False']} value={answer === null ? null : answer ? 0 : 1} onChange={(index) => setAnswer(index === 0)} isRight={(index) => (index === 0) === question.answer} />
                )}
                {question.type === 'bigo' && (
                    <Choices {...choiceProps} mono options={question.options ?? BIG_O_OPTIONS} value={(question.options ?? BIG_O_OPTIONS).indexOf(answer)} onChange={(index) => setAnswer((question.options ?? BIG_O_OPTIONS)[index])} isRight={(index) => (question.options ?? BIG_O_OPTIONS)[index] === question.answer} />
                )}
                {(question.type === 'output' || question.type === 'trace') && (
                    <textarea
                        value={answer}
                        onChange={(event) => setAnswer(event.target.value)}
                        disabled={checked}
                        rows={question.type === 'output' ? Math.max(2, question.answer.split('\n').length) : 2}
                        aria-label={question.type === 'output' ? 'What does it print?' : 'Your answer'}
                        placeholder={question.type === 'output' ? 'Type exactly what it prints…' : 'Your answer…'}
                        autoCapitalize="off"
                        autoCorrect="off"
                        spellCheck={false}
                        className="w-full rounded-xl border border-line bg-[#101217] p-3 font-mono text-[13px] leading-6 outline-none focus:border-amber"
                    />
                )}
                {question.type === 'blank' && <BlankCode code={question.code} answer={answer} onChange={setAnswer} checked={checked} question={question} />}
                {question.type === 'order' && <OrderLines lines={question.lines} answer={answer} onChange={setAnswer} checked={checked} />}
                {question.type === 'bug' && <BugLines name={name} code={question.code} value={answer} onChange={setAnswer} checked={checked} answerLine={question.answer} />}
                {question.type === 'match' && <MatchPairs question={question} answer={answer} onChange={setAnswer} checked={checked} />}
                {question.type === 'estimate' && <Estimate question={question} answer={answer} onChange={setAnswer} checked={checked} />}
                {question.type === 'sort' && <SortItems question={question} answer={answer} onChange={setAnswer} checked={checked} />}
                {isRecall && <Recall question={question} answer={answer} onChange={setAnswer} checked={checked} />}
            </div>

            <div aria-live="polite">
                {checked && (
                    <div className={`mt-4 rounded-xl p-4 text-sm leading-relaxed ${result ? 'bg-[#30D158]/10' : 'bg-[#FF9D96]/10'}`}>
                        <p className={`mb-1 flex items-center gap-2 font-semibold ${result ? 'text-[#30D158]' : 'text-[#FF9D96]'}`}>
                            {result ? <CircleCheck size={18} aria-hidden="true" /> : <CircleX size={18} aria-hidden="true" />}
                            {result ? 'Correct' : 'Not quite'}
                        </p>
                        {!result && rightAnswer && (
                            question.type === 'output' || question.type === 'trace'
                                ? <pre className="my-2 overflow-x-auto rounded-lg bg-black/30 p-3 font-mono text-[13px]">{rightAnswer}</pre>
                                : <p className="mb-1">Answer: <Inline text={rightAnswer} /></p>
                        )}
                        {question.explain && <p className="text-paper/85"><Inline text={question.explain} /></p>}
                    </div>
                )}
            </div>

            {!isRecall && (
                <div className="mt-4 flex flex-wrap gap-2">
                    {!checked && <Button size="sm" variant="primary" onClick={check} disabled={!isAnswered(question, answer)}>Check</Button>}
                    {checked && !result && allowRetry && <Button size="sm" onClick={retry}><RotateCcw size={15} aria-hidden="true" /> Try again</Button>}
                </div>
            )}
            {isRecall && answer !== null && !checked && (
                <div className="mt-4"><Button size="sm" variant="primary" onClick={check}>Save</Button></div>
            )}
        </fieldset>
    );
};

export default Question;

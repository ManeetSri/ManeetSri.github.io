import { useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, Eye, Layers, LoaderCircle, PartyPopper } from 'lucide-react';
import { lessonById } from '../data/curriculum.js';
import { problemById } from '../data/problems.js';
import { useContent } from '../content/index.js';
import { isDue, RATINGS, reviewCard } from '../engine/srs.js';
import { Inline } from '../mdx/inline.jsx';
import Question from '../mdx/quiz/Question.jsx';
import { useActions, useStore } from '../store/store.js';
import { formatDate, relativeDays } from '../ui/format.js';
import { useConsoleMeta, useNow } from '../ui/hooks.js';
import { Button, ButtonLink, Card, Chip, EmptyState, PageHeader } from '../ui/primitives.jsx';

const RATING_STYLES = {
    again: { label: 'Again', className: 'bg-[#FF9D96]/15 text-[#FF9D96]' },
    hard: { label: 'Hard', className: 'bg-amber/15 text-amber' },
    good: { label: 'Good', className: 'bg-[#30D158]/15 text-[#30D158]' },
    easy: { label: 'Easy', className: 'bg-sky-400/15 text-sky-300' },
};

// "Again" brings a card back in ten minutes, so it waits out the rest of this session's queue
const RECENT_MS = 10 * 60_000;

const RateButtons = ({ card, onRate, suggested, now }) => (
    <div role="group" aria-label="How well did you remember it?" className="grid grid-cols-4 gap-2">
        {RATINGS.map((rating) => {
            const next = reviewCard(card, rating, now);
            const when = next.interval === 0 ? 'in 10 minutes' : `in ${next.interval} day${next.interval === 1 ? '' : 's'}`;
            return (
                <button
                    key={rating}
                    type="button"
                    onClick={() => onRate(rating)}
                    aria-label={`${RATING_STYLES[rating].label}, back ${when}`}
                    className={`rounded-xl px-1 py-2.5 text-center transition hover:brightness-125 ${RATING_STYLES[rating].className} ${suggested === rating ? 'ring-2 ring-current' : ''}`}
                >
                    <span className="block text-sm font-semibold">{RATING_STYLES[rating].label}</span>
                    <span className="block font-mono text-[11px] opacity-80">{next.interval === 0 ? '<10m' : `${next.interval}d`}</span>
                </button>
            );
        })}
    </div>
);

const LessonCard = ({ card, onRate, now }) => {
    const content = useContent('lesson', card.lessonId);
    const [revealed, setRevealed] = useState(false);
    const [suggested, setSuggested] = useState(null);
    const lesson = lessonById[card.lessonId];

    if (content.status === 'loading') return <p className="flex items-center gap-2 text-muted" role="status"><LoaderCircle size={18} aria-hidden="true" className="animate-spin" /> Loading…</p>;
    const item = card.kind === 'takeaway'
        ? content.data?.cards.find((entry) => entry.id === card.ref)
        : content.data?.questions.find((entry) => entry.id === card.ref);

    // The lesson changed and this card no longer exists: let it go quietly
    if (!item) {
        return (
            <EmptyState title="This card was retired">
                Its lesson was rewritten. <Button size="sm" className="mt-3" onClick={() => onRate('easy')}>Skip it</Button>
            </EmptyState>
        );
    }

    return (
        <div className="space-y-4">
            <p className="font-mono text-xs text-muted">From <Link to={`/dsa/learn/${lesson.id}`} className="text-amber hover:underline">{lesson.title}</Link></p>
            {card.kind === 'takeaway' ? (
                <Card className="p-5 sm:p-6">
                    <p className="text-xl font-semibold leading-snug"><Inline text={item.front} /></p>
                    {revealed ? (
                        <p className="mt-4 border-t border-line pt-4 leading-relaxed text-paper/85"><Inline text={item.back} /></p>
                    ) : (
                        <Button className="mt-5" onClick={() => setRevealed(true)}><Eye size={16} aria-hidden="true" /> Show the answer</Button>
                    )}
                </Card>
            ) : (
                <Question question={item} onResult={(correct) => { setRevealed(true); setSuggested(correct ? 'good' : 'again'); }} />
            )}
            {revealed && <RateButtons card={card} onRate={onRate} suggested={suggested} now={now} />}
        </div>
    );
};

const ProblemCard = ({ card, onRate, now }) => {
    const problem = problemById[card.ref];
    if (!problem) return <EmptyState title="This problem was retired"><Button size="sm" className="mt-3" onClick={() => onRate('easy')}>Skip it</Button></EmptyState>;
    return (
        <div className="space-y-4">
            <Card className="p-5 sm:p-6">
                <p className="font-mono text-xs text-muted">Re-solve from scratch</p>
                <p className="mt-2 font-display text-2xl font-semibold tracking-tight">{problem.title}</p>
                <p className="mt-2 text-sm leading-relaxed text-muted">Solve it again without looking at your old solution, then rate how it went.</p>
                <ButtonLink to={`/dsa/practice/${problem.id}`} className="mt-4" size="sm">Open the problem <ArrowRight size={15} aria-hidden="true" /></ButtonLink>
            </Card>
            <RateButtons card={card} onRate={onRate} now={now} />
        </div>
    );
};

const ReviewPage = () => {
    useConsoleMeta('Review', '/dsa/review');
    const { cards } = useStore();
    const { review } = useActions();
    const now = useNow(30_000);
    const all = Object.entries(cards).map(([id, card]) => ({ id, ...card }));
    const queue = all
        .filter((card) => isDue(card, now) && !(card.last && now - card.last < RECENT_MS && card.due > now))
        .sort((a, b) => a.due - b.due);
    const reviewedToday = all.filter((card) => card.last && new Date(card.last).toDateString() === new Date(now).toDateString()).length;
    const upcoming = all.filter((card) => !isDue(card, now)).sort((a, b) => a.due - b.due)[0];
    const current = queue[0];

    return (
        <div className="mx-auto max-w-2xl">
            <PageHeader eyebrow={`${queue.length} due · ${reviewedToday} reviewed today · ${all.length} cards in total`} title="Review">
                Recall beats rereading. Answer from memory, then rate honestly: the schedule adapts to you.
            </PageHeader>

            {current ? (
                <div key={current.id}>
                    <div className="mb-4 flex items-center gap-2">
                        <Chip tone="amber">{current.kind === 'problem' ? 'Problem' : current.kind === 'question' ? 'Missed question' : 'Takeaway'}</Chip>
                        {current.lapses > 0 && <Chip tone="red">forgotten {current.lapses}×</Chip>}
                    </div>
                    {current.kind === 'problem'
                        ? <ProblemCard card={current} now={now} onRate={(rating) => review(current.id, rating)} />
                        : <LessonCard card={current} now={now} onRate={(rating) => review(current.id, rating)} />}
                </div>
            ) : all.length === 0 ? (
                <EmptyState icon={Layers} title="No cards yet">
                    Finish a lesson and its takeaways become cards. Questions you miss and problems you solve join them too.
                </EmptyState>
            ) : (
                <EmptyState icon={PartyPopper} title="All caught up">
                    {upcoming ? <>The next card is due {relativeDays(upcoming.due, now)} ({formatDate(upcoming.due, { weekday: 'long', day: 'numeric', month: 'short' })}).</> : 'Nothing scheduled.'}
                </EmptyState>
            )}
        </div>
    );
};

export default ReviewPage;

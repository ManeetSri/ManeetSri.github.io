import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ArrowRight, Award, CheckCircle2, CircleX, LoaderCircle, RotateCcw, SkipForward } from 'lucide-react';
import { moduleById } from '../data/curriculum.js';
import { loadContent } from '../content/index.js';
import { isDone } from '../engine/path.js';
import Question from '../mdx/quiz/Question.jsx';
import { useActions, useStore } from '../store/store.js';
import { formatDate } from '../ui/format.js';
import { useConsoleMeta } from '../ui/hooks.js';
import { Button, ButtonLink, Card, EmptyState, PageHeader, ProgressBar } from '../ui/primitives.jsx';
import ConsoleNotFound from './ConsoleNotFound.jsx';

const QUESTION_COUNT = 12;
const PASS_MARK = 0.8;

// Questions from every written lesson in the module. Self-graded ones are left out, so the score is objective.
const loadQuestions = async (module) => {
    const loaded = await Promise.all(module.lessons.filter((lesson) => lesson.status === 'ready').map(async (lesson) => {
        const content = await loadContent('lesson', lesson.id);
        return (content?.data.questions ?? [])
            .filter((question) => question.type !== 'recall')
            .map((question) => ({ ...question, key: `${lesson.id}~${question.id}`, lesson }));
    }));
    const pool = loaded.flat();
    for (let index = pool.length - 1; index > 0; index -= 1) {
        const swap = Math.floor(Math.random() * (index + 1));
        [pool[index], pool[swap]] = [pool[swap], pool[index]];
    }
    return pool.slice(0, QUESTION_COUNT);
};

const Results = ({ module, questions, answers, onRetake }) => {
    const { lessons } = useStore();
    const { testOut } = useActions();
    const [testedOut, setTestedOut] = useState(false);
    const score = questions.filter((question) => answers[question.key]).length;
    const passed = score / questions.length >= PASS_MARK;
    const unfinished = module.lessons.filter((lesson) => lesson.status === 'ready' && !isDone(lesson.id, lessons));
    const missed = questions.filter((question) => !answers[question.key]);

    return (
        <div className="space-y-6">
            <Card className={`p-6 text-center ${passed ? 'border-[#30D158]/40' : ''}`}>
                {passed ? <Award size={40} aria-hidden="true" className="mx-auto text-amber" /> : <RotateCcw size={36} aria-hidden="true" className="mx-auto text-muted" />}
                <p className="mt-3 font-display text-5xl font-semibold tracking-tight">{score} / {questions.length}</p>
                <p className="mt-2 text-lg">{passed ? `${module.title} mastered.` : `Not quite: you need ${Math.ceil(questions.length * PASS_MARK)} to pass.`}</p>
                <p className="mt-1 text-sm text-muted">{passed ? 'That’s worth 200 XP the first time.' : 'Revisit the lessons below, then try again. The questions change each time.'}</p>
            </Card>

            {passed && unfinished.length > 0 && (
                <Card className="flex flex-wrap items-center gap-3 p-5">
                    <SkipForward size={20} aria-hidden="true" className="shrink-0 text-amber" />
                    <p className="min-w-48 flex-1 text-sm">You passed without finishing {unfinished.length} lesson{unfinished.length === 1 ? '' : 's'}. Mark {unfinished.length === 1 ? 'it' : 'them'} as tested out, so your path moves on?</p>
                    <Button size="sm" disabled={testedOut} onClick={() => { testOut(unfinished.map((lesson) => lesson.id)); setTestedOut(true); }}>
                        {testedOut ? 'Done' : 'Test out'}
                    </Button>
                </Card>
            )}

            {missed.length > 0 && (
                <Card className="p-5">
                    <h2 className="mb-3 font-semibold">Worth revisiting</h2>
                    <ul className="space-y-2">
                        {missed.map((question) => (
                            <li key={question.key} className="flex items-start gap-2 text-sm">
                                <CircleX size={16} aria-hidden="true" className="mt-0.5 shrink-0 text-[#FF9D96]" />
                                <span><Link to={`/dsa/learn/${question.lesson.id}`} className="text-amber hover:underline">{question.lesson.title}</Link></span>
                            </li>
                        ))}
                    </ul>
                </Card>
            )}

            <div className="flex flex-wrap gap-2">
                <Button onClick={onRetake}><RotateCcw size={16} aria-hidden="true" /> Take it again</Button>
                <ButtonLink to="/dsa/path" variant="primary">Back to the path <ArrowRight size={16} aria-hidden="true" /></ButtonLink>
            </div>
        </div>
    );
};

const CheckpointView = ({ module }) => {
    useConsoleMeta(`${module.code} checkpoint`, `/dsa/checkpoint/${module.id}`);
    const { checkpoints } = useStore();
    const { recordCheckpoint } = useActions();
    const record = checkpoints[module.id];
    const attempts = Object.values(record?.attempts ?? {}).sort((a, b) => b.at - a.at);
    const best = attempts.reduce((top, attempt) => Math.max(top, attempt.score / attempt.total), 0);
    const [stage, setStage] = useState('intro');
    const [questions, setQuestions] = useState([]);
    const [index, setIndex] = useState(0);
    const [answers, setAnswers] = useState({});
    const [round, setRound] = useState(0);

    useEffect(() => {
        if (stage !== 'loading') return undefined;
        let cancelled = false;
        loadQuestions(module).then((picked) => {
            if (cancelled) return;
            setQuestions(picked);
            setIndex(0);
            setAnswers({});
            setStage(picked.length ? 'quiz' : 'empty');
        });
        return () => {
            cancelled = true;
        };
    }, [stage, module, round]);

    const question = questions[index];
    const answered = question && question.key in answers;
    const last = index === questions.length - 1;

    const finish = () => {
        const score = questions.filter((item) => answers[item.key]).length;
        recordCheckpoint(module.id, { score, total: questions.length, passed: score / questions.length >= PASS_MARK });
        setStage('results');
    };

    const start = () => {
        setRound((value) => value + 1);
        setStage('loading');
    };

    return (
        <div className="mx-auto max-w-2xl">
            <PageHeader eyebrow={`${module.code} · Checkpoint`} title={module.title}>
                {stage === 'intro' && `${QUESTION_COUNT} questions drawn from across the module, one at a time, first answers only. Score ${Math.round(PASS_MARK * 100)}% or more to master it.`}
            </PageHeader>

            {stage === 'intro' && (
                <div className="space-y-5">
                    {record?.passedAt && (
                        <p className="flex items-center gap-2 text-[#30D158]"><CheckCircle2 size={18} aria-hidden="true" /> Mastered on {formatDate(record.passedAt)}. Retaking is great revision.</p>
                    )}
                    {attempts.length > 0 && <p className="text-sm text-muted">{attempts.length} attempt{attempts.length === 1 ? '' : 's'} so far · best {Math.round(best * 100)}%</p>}
                    <Button variant="primary" onClick={start}>Start the checkpoint <ArrowRight size={18} aria-hidden="true" /></Button>
                </div>
            )}

            {stage === 'loading' && <p className="flex items-center gap-2 text-muted" role="status"><LoaderCircle size={18} aria-hidden="true" className="animate-spin" /> Picking questions…</p>}

            {stage === 'empty' && <EmptyState title="No questions yet">This module’s lessons aren’t written yet. Its checkpoint opens when they are.</EmptyState>}

            {stage === 'quiz' && question && (
                <div>
                    <div className="mb-4 flex justify-between font-mono text-xs text-muted">
                        <span>Question {index + 1} of {questions.length}</span>
                        <span>From “{question.lesson.title}”</span>
                    </div>
                    <ProgressBar value={(index + (answered ? 1 : 0)) / questions.length} label="Checkpoint progress" className="mb-5" />
                    <Question
                        key={question.key}
                        question={question}
                        allowRetry={false}
                        onResult={(correct) => setAnswers((current) => (question.key in current ? current : { ...current, [question.key]: correct }))}
                    />
                    <div className="mt-5 flex justify-end">
                        <Button variant="primary" disabled={!answered} onClick={() => (last ? finish() : setIndex(index + 1))}>
                            {last ? 'See my score' : 'Next question'} <ArrowRight size={18} aria-hidden="true" />
                        </Button>
                    </div>
                </div>
            )}

            {stage === 'results' && <Results module={module} questions={questions} answers={answers} onRetake={start} />}
        </div>
    );
};

const CheckpointPage = () => {
    const { moduleId } = useParams();
    const module = moduleById[moduleId];
    if (!module) return <ConsoleNotFound />;
    return <CheckpointView key={module.id} module={module} />;
};

export default CheckpointPage;

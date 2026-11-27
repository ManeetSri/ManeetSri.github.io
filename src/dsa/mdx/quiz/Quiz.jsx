import { ListChecks } from 'lucide-react';
import { useActions, useStore } from '../../store/store.js';
import { useLessonContext } from '../lessonContext.js';
import Question from './Question.jsx';

// A ```quiz block in a lesson. Answers are saved against the lesson, and a question missed on the first
// try becomes a review card.
const Quiz = ({ data }) => {
    const { questions } = JSON.parse(data);
    const lesson = useLessonContext();
    const { lessons } = useStore();
    const { recordAnswer } = useActions();
    const saved = lesson ? lessons[lesson.lessonId]?.quiz ?? {} : {};
    const correct = questions.filter((question) => saved[question.id]?.correct).length;

    return (
        <section aria-label="Quiz" className="my-8 space-y-4">
            <div className="flex items-center gap-3">
                <span className="flex h-9 w-9 items-center justify-center rounded-full bg-amber/15 text-amber"><ListChecks size={18} aria-hidden="true" /></span>
                <div>
                    <p className="font-semibold">Check your understanding</p>
                    <p className="font-mono text-xs text-muted">{correct} of {questions.length} answered correctly</p>
                </div>
            </div>
            {questions.map((question, index) => (
                <Question
                    key={question.id}
                    question={question}
                    number={index + 1}
                    previous={saved[question.id]}
                    onResult={(isRight) => lesson && recordAnswer(lesson.lessonId, question.id, isRight)}
                />
            ))}
        </section>
    );
};

export default Quiz;

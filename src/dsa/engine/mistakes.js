// The mistakes log, derived from recorded facts like everything else: quiz questions missed on the first try,
// problems not yet solved cleanly (or last rated Again or Hard), and mock interviews that went badly.
// Each list is newest first, so the weekly review starts with what's freshest.

const latestAttempt = (record) => Object.values(record.attempts ?? {}).sort((a, b) => b.at - a.at)[0];

export const quizMistakes = (lessons, lessonById) => Object.entries(lessons)
    .filter(([id]) => lessonById[id])
    .map(([id, record]) => {
        const missed = Object.values(record.quiz ?? {}).filter((answer) => answer.firstTry === false);
        return { lessonId: id, missed: missed.length, stillWrong: missed.filter((answer) => !answer.correct).length, at: Math.max(0, ...missed.map((answer) => answer.at ?? 0)) };
    })
    .filter((entry) => entry.missed > 0)
    .sort((a, b) => b.at - a.at);

export const problemMistakes = (problems, problemById) => Object.entries(problems)
    .filter(([id]) => problemById[id])
    .map(([id, record]) => {
        const last = latestAttempt(record);
        const reason = record.status === 'attempted' ? 'not solved yet'
            : record.status === 'helped' ? 'solved with help'
                : last?.rating === 'again' || last?.rating === 'hard' ? `last rated ${last.rating}` : null;
        return { problemId: id, reason, at: last?.at ?? 0 };
    })
    .filter((entry) => entry.reason)
    .sort((a, b) => b.at - a.at);

// A mock averaging under 2.5 out of 4 is worth another look
export const mockMistakes = (mocks) => Object.values(mocks)
    .map((mock) => {
        const scores = Object.values(mock.scores ?? {});
        const average = scores.length ? scores.reduce((sum, value) => sum + value, 0) / scores.length : 0;
        const weakest = Object.entries(mock.scores ?? {}).sort(([, a], [, b]) => a - b)[0]?.[0];
        return { ...mock, average, weakest };
    })
    .filter((mock) => mock.status !== 'solved' || mock.average < 2.5)
    .sort((a, b) => b.at - a.at);

// Design exercises and reviews worth another look: not solved, a skill scored 2 or less, or findings missed
export const designMistakes = (designs, practiceById, skillLabels = {}) => Object.entries(designs)
    .filter(([id]) => practiceById[id])
    .map(([id, record]) => {
        const last = latestAttempt(record);
        if (!last) return null;
        const weakSkills = Object.entries(last.skills ?? {}).filter(([, score]) => score <= 2).map(([skill]) => skillLabels[skill] ?? skill);
        const missedSome = Object.values(last.marks ?? {}).includes('missed');
        const reason = last.status !== 'solved' ? (last.status === 'helped' ? 'partly there' : 'not there yet')
            : weakSkills.length ? `weak on ${weakSkills.join(', ')}`
                : missedSome ? 'missed findings' : null;
        return reason ? { designId: id, reason, at: last.at } : null;
    })
    .filter(Boolean)
    .sort((a, b) => b.at - a.at);

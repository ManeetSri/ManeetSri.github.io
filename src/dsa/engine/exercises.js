// Scoring for self-assessed practice: rubrics (mock interviews and design exercises) and architecture
// reviews (which expected findings you spotted). Each turns into a spaced-repetition rating and a status.

const average = (values) => (values.length ? values.reduce((sum, value) => sum + value, 0) / values.length : 0);

// Rubric scores run 1 (not yet) to 4 (strong)
export const rubricAverage = (scores = {}) => average(Object.values(scores));

// The thresholds the DSA mock interview has always used
export const ratingFromRubric = (scores, status) => {
    const mean = rubricAverage(scores);
    if (status === 'attempted' || mean < 2) return 'again';
    if (mean < 2.75) return 'hard';
    if (mean < 3.5) return 'good';
    return 'easy';
};

export const statusFromRubric = (scores) => {
    const mean = rubricAverage(scores);
    if (mean >= 2.75) return 'solved';
    if (mean >= 2) return 'helped';
    return 'attempted';
};

// The lowest score per skill: a design is only as strong as its weakest area
export const skillScores = (scores = {}, criteria = []) => criteria.reduce((skills, criterion) => {
    const score = scores[criterion.id];
    if (score === undefined || !criterion.skill) return skills;
    return { ...skills, [criterion.skill]: Math.min(skills[criterion.skill] ?? 4, score) };
}, {});

const SEVERITY_WEIGHT = { high: 3, medium: 2, low: 1 };
const MARK_VALUE = { found: 1, partial: 0.5, missed: 0 };

// The share of an architecture review's expected findings you spotted, weighted by severity
export const critiqueScore = (marks = {}, findings = []) => {
    const total = findings.reduce((sum, finding) => sum + (SEVERITY_WEIGHT[finding.severity] ?? 1), 0);
    const earned = findings.reduce((sum, finding) => sum + (SEVERITY_WEIGHT[finding.severity] ?? 1) * (MARK_VALUE[marks[finding.id]] ?? 0), 0);
    return total ? earned / total : 0;
};

export const ratingFromCritique = (score) => {
    if (score >= 0.85) return 'easy';
    if (score >= 0.65) return 'good';
    if (score >= 0.4) return 'hard';
    return 'again';
};

export const statusFromCritique = (score) => {
    if (score >= 0.65) return 'solved';
    if (score >= 0.4) return 'helped';
    return 'attempted';
};

// Your latest score for each design skill (1–4), across every scored design: what Progress charts
export const latestSkills = (designs = {}) => {
    const latest = {};
    Object.values(designs).flatMap((record) => Object.values(record.attempts ?? {}))
        .filter((attempt) => attempt.skills)
        .sort((a, b) => a.at - b.at)
        .forEach((attempt) => Object.assign(latest, attempt.skills));
    return latest;
};

// Settings that belong to one course: goal, pace, target date, setup and placement. DSA keeps them at the
// top of meta/profile, where they always were; every other course has meta/profile.courses.{id}. A reset
// course is stored as nulls, which read as the defaults. Text size is the same in every course.
export const COURSE_FIELDS = ['goal', 'minutesPerDay', 'daysPerWeek', 'targetDate', 'onboardedAt', 'placement'];

const DEFAULTS = { minutesPerDay: 45, daysPerWeek: 5, targetDate: null };

const withoutNulls = (record) => Object.fromEntries(Object.entries(record ?? {}).filter(([, value]) => value !== null && value !== undefined));

export const courseProfile = (profile = {}, course) => {
    const slot = course.profileSlot ? profile.courses?.[course.profileSlot] : profile;
    const own = Object.fromEntries(Object.entries(withoutNulls(slot)).filter(([key]) => COURSE_FIELDS.includes(key)));
    return { ...DEFAULTS, goal: course.defaultGoal, ...own, textSize: profile.textSize ?? 'normal' };
};

// The patch to write to meta/profile for a course's fields
export const profilePatch = (course, patch) => (course.profileSlot ? { courses: { [course.profileSlot]: patch } } : patch);

import { createContext, useContext } from 'react';

// Lets quiz questions inside a lesson's MDX record answers against that lesson
export const LessonContext = createContext(null);

export const useLessonContext = () => useContext(LessonContext);

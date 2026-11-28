// The course a page belongs to. Every console page reads its curriculum, practice items, links and copy from
// here instead of importing one course's data, so the same pages serve every course.
import { createContext, useContext } from 'react';

export const CourseContext = createContext(null);

export const useCourse = () => useContext(CourseContext);

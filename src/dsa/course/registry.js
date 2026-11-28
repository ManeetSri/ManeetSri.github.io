// Every course's data, safe to import from Node (engines, tests, scripts). The UI's course objects in
// courses.js wrap these with links, copy and content loaders.
import { dsaData } from '../data/courseData.js';

export const COURSE_DATA = { dsa: dsaData };

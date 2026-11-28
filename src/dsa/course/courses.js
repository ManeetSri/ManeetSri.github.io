// Every course the console hosts, keyed by id
import { dsaCourse } from '../data/course.js';
import { designCourse } from '../design/data/course.js';

export const COURSES = { dsa: dsaCourse, design: designCourse };

export const courseList = Object.values(COURSES);

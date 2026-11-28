// Every course the console hosts, keyed by id
import { dsaCourse } from '../data/course.js';

export const COURSES = { dsa: dsaCourse };

export const courseList = Object.values(COURSES);

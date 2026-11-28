// What a design exercise's model-answer blocks need from the page: whether the answer is revealed yet,
// the learner's own answer per section (shown beside the model), and the section titles.
// Without a page around them (a stray render), everything shows.
import { createContext, useContext } from 'react';

export const DesignAnswerContext = createContext({ revealed: true, answers: {}, sections: [] });

export const useDesignAnswer = () => useContext(DesignAnswerContext);

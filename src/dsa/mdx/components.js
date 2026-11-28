import CodeBlock from './CodeBlock.jsx';
import Quiz from './quiz/Quiz.jsx';
import Visual from './Visual.jsx';
import { Approach, Callout, Hint, Hints, Takeaways } from './Blocks.jsx';
import { Brief, ModelAnswer, Pitfalls, ReferenceReview } from './DesignBlocks.jsx';
import {
    Anchor, Cell, H2, H3, HeaderCell, InlineCode, List, ListItem, OrderedList, Paragraph, Quote, Rule, Strong, Table, TableHead,
} from './Markdown.jsx';

// Plain markdown elements, plus the components lessons can use by name
export const mdxComponents = {
    h2: H2,
    h3: H3,
    p: Paragraph,
    ul: List,
    ol: OrderedList,
    li: ListItem,
    a: Anchor,
    strong: Strong,
    code: InlineCode,
    blockquote: Quote,
    hr: Rule,
    table: Table,
    thead: TableHead,
    th: HeaderCell,
    td: Cell,
    CodeBlock,
    Quiz,
    Takeaways,
    Visual,
    Callout,
    Hints,
    Hint,
    Approach,
    Brief,
    ModelAnswer,
    Pitfalls,
    ReferenceReview,
};

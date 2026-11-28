import { Children } from 'react';

const textOf = (children) => Children.toArray(children).map((child) => (typeof child === 'string' ? child : textOf(child?.props?.children))).join('');

// Matches slugify() in scripts/remark-dsa-blocks.js, which lists each lesson's headings
export const slugify = (children) => textOf(children).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');

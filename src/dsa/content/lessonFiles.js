import { byId } from './files.js';

export default byId(import.meta.glob('./lessons/**/*.mdx'));

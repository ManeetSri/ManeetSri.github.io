import { byId } from '../../content/files.js';

export default byId(import.meta.glob('./lessons/**/*.mdx'));

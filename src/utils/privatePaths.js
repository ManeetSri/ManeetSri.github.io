// The learning console is private: no analytics, no portfolio chrome, never indexed. Each course has its own
// base path. This file has no imports, so the build's header plugin can read it too.
export const CONSOLE_BASES = ['/dsa', '/design'];

export const isPrivatePath = (pathname) => CONSOLE_BASES.some((base) => pathname === base || pathname.startsWith(`${base}/`));

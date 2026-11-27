// The learning console is private: no analytics, no portfolio chrome, never indexed
export const isPrivatePath = (pathname) => pathname === '/dsa' || pathname.startsWith('/dsa/');

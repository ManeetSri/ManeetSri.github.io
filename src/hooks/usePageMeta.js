import { useEffect } from 'react';

const SITE_URL = 'https://maneet-srivastav.netlify.app';

const setMeta = (attribute, name, content) => {
    let tag = document.head.querySelector(`meta[${attribute}="${name}"]`);
    if (!tag) {
        tag = document.createElement('meta');
        tag.setAttribute(attribute, name);
        document.head.appendChild(tag);
    }
    tag.setAttribute('content', content);
};

// Each route gets its own title, description and canonical URL
export const usePageMeta = ({ title, description, path, noindex = false }) => {
    useEffect(() => {
        const url = `${SITE_URL}${path}`;
        document.title = title;
        setMeta('name', 'description', description);
        setMeta('property', 'og:title', title);
        setMeta('property', 'og:description', description);
        setMeta('property', 'og:url', url);
        document.head.querySelector('link[rel="canonical"]')?.setAttribute('href', url);
        setMeta('name', 'robots', noindex ? 'noindex' : 'index, follow');
    }, [title, description, path, noindex]);
};

import { useState, useEffect } from 'react';

export const MEDIUM_PROFILE_URL = 'https://medium.com/@maneetsrivastav';

const FEED_URL = 'https://api.rss2json.com/v1/api.json?rss_url=https://medium.com/feed/@maneetsrivastav';

const WORDS_PER_MINUTE = 200;
const MAX_POSTS = 20;
const MAX_TITLE_LENGTH = 200;
const MAX_EXCERPT_LENGTH = 600;
const MAX_CONTENT_LENGTH = 200000;
const FETCH_TIMEOUT_MS = 8000;
const parseHtml = (html) => new DOMParser().parseFromString(html, 'text/html');

// The feed's description opens with the title and ends with a link back to Medium
const toExcerpt = (html) => {
    const doc = parseHtml(html);
    doc.querySelectorAll('h1, h2, h3, h4, figure, img').forEach((node) => node.remove());
    return doc.body.textContent.replace(/Continue reading on .*$/s, '').replace(/\s+/g, ' ').trim();
};

const isMediumHost = (hostname) => hostname === 'medium.com' || hostname.endsWith('.medium.com');
const isCoverHost = (hostname) => hostname === 'cdn-images-1.medium.com';

// Only https links on the expected hosts get through, which rules out javascript: links and the like
const safeUrl = (value, isAllowedHost) => {
    try {
        const url = new URL(value);
        return url.protocol === 'https:' && isAllowedHost(url.hostname) ? url.href : null;
    } catch {
        return null;
    }
};

const text = (value, maxLength) => (typeof value === 'string' ? value.slice(0, maxLength) : '');

// The feed leaves its thumbnail empty, so the cover is the first real image in the article.
// DOMParser builds an inert document: its scripts don't run and its images don't load.
const toPost = (item) => {
    const link = safeUrl(item?.link, isMediumHost);
    const title = text(item?.title, MAX_TITLE_LENGTH);
    if (!link || !title) return null;

    const content = parseHtml(text(item.content, MAX_CONTENT_LENGTH));
    const cover = [...content.images].map((image) => safeUrl(image.src, isCoverHost)).find(Boolean);
    const words = content.body.textContent.trim().split(/\s+/).length;
    const guid = text(item.guid, 200) || link;

    return {
        title,
        link,
        guid,
        pubDate: text(item.pubDate, 40),
        cover: cover?.replace('/max/1024/', '/max/800/'),
        excerpt: toExcerpt(text(item.description, MAX_CONTENT_LENGTH)).slice(0, MAX_EXCERPT_LENGTH),
        readMinutes: Math.max(1, Math.ceil(words / WORDS_PER_MINUTE)),
        tags: (Array.isArray(item.categories) ? item.categories : []).filter((tag) => typeof tag === 'string').slice(0, 3).map((tag) => tag.slice(0, 40)),
        // Medium's guid ends in the post's id, which makes a genuine short hash
        hash: guid.split('/').pop().slice(0, 7),
    };
};

export const formatDate = (dateString) => {
    const options = { year: 'numeric', month: 'short', day: 'numeric' };
    return new Date(dateString).toLocaleDateString(undefined, options);
};

export const useMediumPosts = () => {
    const [posts, setPosts] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const controller = new AbortController();
        const timer = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);
        let isCurrent = true;

        const fetchPosts = async () => {
            try {
                const response = await fetch(FEED_URL, {
                    signal: controller.signal,
                    credentials: 'omit',
                    referrerPolicy: 'no-referrer',
                });
                const data = await response.json();
                if (isCurrent && data?.status === 'ok' && Array.isArray(data.items)) {
                    setPosts(data.items.slice(0, MAX_POSTS).map(toPost).filter(Boolean));
                }
            } catch (error) {
                if (isCurrent) console.error('Error fetching Medium posts:', error);
            } finally {
                clearTimeout(timer);
                if (isCurrent) setLoading(false);
            }
        };

        fetchPosts();
        return () => {
            isCurrent = false;
            clearTimeout(timer);
            controller.abort();
        };
    }, []);

    return { posts, loading };
};

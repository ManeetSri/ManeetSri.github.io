import { useState, useEffect } from 'react';

export const MEDIUM_PROFILE_URL = 'https://medium.com/@maneetsrivastav';

const FEED_URL = 'https://api.rss2json.com/v1/api.json?rss_url=https://medium.com/feed/@maneetsrivastav';

const WORDS_PER_MINUTE = 200;
const parseHtml = (html) => new DOMParser().parseFromString(html, 'text/html');

// The feed's description opens with the title and ends with a link back to Medium
const toExcerpt = (html) => {
    const doc = parseHtml(html);
    doc.querySelectorAll('h1, h2, h3, h4, figure, img').forEach((node) => node.remove());
    return doc.body.textContent.replace(/Continue reading on .*$/s, '').replace(/\s+/g, ' ').trim();
};

// The feed leaves its thumbnail empty, so the cover is the first real image in the article
const toPost = (item) => {
    const content = parseHtml(item.content);
    const cover = [...content.images].find((image) => image.src.includes('cdn-images-1.medium.com'));
    const words = content.body.textContent.trim().split(/\s+/).length;

    return {
        ...item,
        cover: cover?.src.replace('/max/1024/', '/max/800/'),
        excerpt: toExcerpt(item.description),
        readMinutes: Math.max(1, Math.ceil(words / WORDS_PER_MINUTE)),
        tags: item.categories.slice(0, 3),
        // Medium's guid ends in the post's id, which makes a genuine short hash
        hash: item.guid.split('/').pop().slice(0, 7),
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
        const fetchPosts = async () => {
            try {
                const response = await fetch(FEED_URL);
                const data = await response.json();
                if (data.status === 'ok') {
                    setPosts(data.items.map(toPost));
                }
            } catch (error) {
                console.error('Error fetching Medium posts:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchPosts();
    }, []);

    return { posts, loading };
};

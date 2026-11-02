import { useState, useEffect } from 'react';

export const MEDIUM_PROFILE_URL = 'https://medium.com/@maneetsrivastav';

const FEED_URL = 'https://api.rss2json.com/v1/api.json?rss_url=https://medium.com/feed/@maneetsrivastav';

// Helper to strip HTML tags for preview text
export const stripHtml = (html) => {
    const doc = new DOMParser().parseFromString(html, 'text/html');
    return doc.body.textContent || "";
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
                    setPosts(data.items);
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

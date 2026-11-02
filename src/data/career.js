const CAREER_START = new Date(2022, 10); // Nov 2022

export const getYearsOfExperience = () => {
    const now = new Date();
    const months = (now.getFullYear() - CAREER_START.getFullYear()) * 12
        + now.getMonth() - CAREER_START.getMonth();
    return Math.floor(months / 12);
};

// Oldest first. Dates and notes come from the resume; only the version numbers are a metaphor.
export const career = [
    {
        id: 'synclovis',
        version: '1.0',
        label: 'Initial release',
        company: 'Synclovis Systems',
        shortName: 'Synclovis',
        role: 'Software Engineer',
        period: 'Nov 2022 – Nov 2023',
        location: 'Bengaluru',
        start: [2022, 11],
        end: [2023, 11],
        notes: [
            'Started my iOS journey with SwiftUI & UIKit.',
            'Worked on e-commerce features and school management flows.',
            'Built strong foundations in architecture and delivery.',
        ],
    },
    {
        id: 'jamtech',
        version: '2.0',
        label: 'New: video & in-app purchases',
        company: 'JamTech Technologies',
        shortName: 'JamTech',
        role: 'iOS Developer',
        period: 'Dec 2023 – April 2024',
        location: 'Lucknow',
        start: [2023, 12],
        end: [2024, 4],
        notes: [
            'Developed a job-board iOS app with swipe-based discovery.',
            'Added video resume recording and in-app purchase flows.',
        ],
    },
    {
        id: 'singsys',
        version: '3.0',
        label: 'Major update: a full ride-hailing ecosystem',
        company: 'Singsys',
        shortName: 'Singsys',
        role: 'Software Engineer – Mobile',
        period: 'May 2024 – May 2025',
        location: 'Lucknow',
        start: [2024, 5],
        end: [2025, 5],
        notes: [
            'Architected and shipped user and driver apps with maps, routing, payments and real-time updates.',
            'Delivered multi-domain apps using Swift, SwiftUI & React Native.',
            'Led the development team in line with client requirements.',
        ],
    },
    {
        id: 'codeflies',
        version: '4.0',
        label: 'New: subscriptions & App Store delivery',
        company: 'Codeflies Technologies',
        shortName: 'Codeflies',
        role: 'iOS Developer',
        period: 'June 2025 – Sept 2025',
        location: 'Noida',
        start: [2025, 6],
        end: [2025, 9],
        notes: [
            'Integrated subscription and purchase models.',
            'Deployed apps to the Apple App Store in line with its policies.',
        ],
    },
    {
        id: 'mahindra',
        version: '5.0',
        label: 'Current version',
        company: 'Mahindra Logistics',
        shortName: 'Mahindra',
        role: 'Assistant Manager – IT (Specialist – Mobile Application)',
        period: 'Sept 2025 – Present',
        location: 'Gurugram',
        start: [2025, 9],
        end: null,
        notes: [
            'Building and optimizing enterprise mobility apps using Swift, Core Data and MVC-based architectures.',
            'Focused on scalable workflows for logistics & operations teams.',
        ],
    },
];

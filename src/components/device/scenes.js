import { lazy } from 'react';

const LOADERS = {
    alyte: () => import('../../scenes/AlyteScene'),
    empowered: () => import('../../scenes/EmpoweredScene'),
    best: () => import('../../scenes/BestScene'),
    imperium: () => import('../../scenes/ImperiumScene'),
    spiritual: () => import('../../scenes/SpiritualScene'),
    bluewings: () => import('../../scenes/BluewingsScene'),
    bodyinc: () => import('../../scenes/BodyIncScene'),
    countrypicker: () => import('../../scenes/CountryPickerScene'),
};

export const SCENES = Object.fromEntries(
    Object.entries(LOADERS).map(([id, loader]) => [id, lazy(loader)]),
);

// Fetches every scene up front, so nothing has to load mid-scroll and cause a stutter
export const preloadScenes = () => {
    Object.values(LOADERS).forEach((loader) => loader());
};

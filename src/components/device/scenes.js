import { lazy } from 'react';

export const SCENES = {
    alyte: lazy(() => import('../../scenes/AlyteScene')),
    empowered: lazy(() => import('../../scenes/EmpoweredScene')),
    best: lazy(() => import('../../scenes/BestScene')),
    imperium: lazy(() => import('../../scenes/ImperiumScene')),
    spiritual: lazy(() => import('../../scenes/SpiritualScene')),
    bluewings: lazy(() => import('../../scenes/BluewingsScene')),
    bodyinc: lazy(() => import('../../scenes/BodyIncScene')),
    countrypicker: lazy(() => import('../../scenes/CountryPickerScene')),
};

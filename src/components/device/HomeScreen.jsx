import { BookOpen, FileText, Github, Mail } from 'lucide-react';
import AppIcon from './AppIcon';
import { projects } from '../../data/projects';
import { ICON_SIZE, iconPosition } from '../../data/workTimeline';

const SHORT_NAMES = { empowered: 'EmpowerED', best: 'Best', imperium: 'Imperium', spiritual: 'Spiritual Q', bluewings: 'Bluewings', countrypicker: 'CountryPicker' };

const DOCK = [Github, BookOpen, Mail, FileText];

const HomeScreen = () => (
    <div aria-hidden="true" className="absolute inset-0 bg-[radial-gradient(110%_60%_at_20%_0%,#3a1a12_0%,#14161c_55%,#0a0b0f_100%)]">
        {projects.map((project, index) => {
            const { x, y } = iconPosition(index);
            return (
                <div key={project.id} className="absolute flex flex-col items-center" style={{ left: x, top: y, width: ICON_SIZE }}>
                    <AppIcon project={project} size={ICON_SIZE} />
                    <span className="mt-1 w-[66px] truncate text-center text-[11px] text-white/85">
                        {SHORT_NAMES[project.id] ?? project.title}
                    </span>
                </div>
            );
        })}
        <div className="absolute inset-x-3 bottom-3 flex justify-around rounded-[28px] bg-white/10 p-2.5">
            {DOCK.map((Icon, index) => (
                <span key={index} className="flex h-[52px] w-[52px] items-center justify-center rounded-[13px] bg-white/10">
                    <Icon size={24} className="text-white/85" />
                </span>
            ))}
        </div>
    </div>
);

export default HomeScreen;

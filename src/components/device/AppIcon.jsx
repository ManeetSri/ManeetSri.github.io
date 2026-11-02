const AppIcon = ({ project, size = 56 }) => {
    const style = { width: size, height: size, borderRadius: size * 0.225 };

    if (project.icon) {
        return <img src={project.icon} alt="" width={size} height={size} draggable={false} className="object-cover" style={style} />;
    }

    // Unlisted or open-source projects have no App Store artwork to show
    return (
        <span
            className="flex items-center justify-center font-semibold text-ink"
            style={{ ...style, background: project.tint, fontSize: size * 0.34 }}
        >
            {project.monogram}
        </span>
    );
};

export default AppIcon;

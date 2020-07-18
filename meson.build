# Project name and programming language
project('io.github.coslyk.bingle', 'vala', 'c', version: '0.1')

# Import Meson modules
gnome = import('gnome')

# Compile resource files
asresources = gnome.compile_resources(
    'as-resources', join_paths('data', 'app.gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)

# Create a new executable, list the files we want to compile, list the dependencies we need
executable(
    meson.project_name(),
    'src/Application.vala',
    'src/DesktopService.vala',
    'src/Provider.vala',
    'src/Gallery.vala',
    'src/ImageData.vala',
    'src/ImageViewer.vala',
    'src/MainWindow.vala',
    asresources,
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('libsoup-2.4'),
        dependency('json-glib-1.0')
    ],
    install: true
)

# Install our .desktop file so the Applications Menu will see it
install_data(
    join_paths('data', meson.project_name() + '.desktop'),
    install_dir: join_paths(get_option('datadir'), 'applications')
)

# Project name and programming language
project('io.github.coslyk.bingle', 'vala', 'c', version: '0.1')

# Import the translations module
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

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
        dependency('json-glib-1.0'),
        meson.get_compiler('vala').find_library('posix')
    ],
    install: true
)

# Install our .desktop file so the Applications Menu will see it
install_data(
    join_paths('data', meson.project_name() + '.desktop'),
    install_dir: join_paths(get_option('datadir'), 'applications')
)

# Install our icon file
install_data(
    join_paths('data', meson.project_name() + '.png'),
    install_dir: join_paths(get_option('datadir'), 'icons')
)

# Install our .appdata.xml file
install_data(
    join_paths('data', meson.project_name() + '.appdata.xml'),
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

# Translation files
subdir('po')

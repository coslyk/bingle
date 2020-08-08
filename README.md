# Bingle
Download and manage wallpapers from Bing.

***

### Homepage

The homepage of Bingle is: https://coslyk.github.io/bingle.html

Here is the development page of this project. For the program usage information, please visit the homepage.

### Compile

Following packages are essential for compiling Bingle.

On ArchLinux:

```
    - vala
    - meson
    - gtk3
    - json-glib
    - libsoup
```

On Debian:

```
    - valac
    - meson
    - libgtk-3-dev
    - libjson-glib-dev
    - libsoup2.4-dev

```

Other Linux: Please diy.

Download the source code, then run:

```bash
meson build
ninja -C build
sudo ninja -C build install
```

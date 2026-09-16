Retrosmart vector X11 cursors
-----------------------------

## This is the vectorized version of [Retrosmart X11 cursors](https://github.com/mdomlop/retrosmart-x11-cursors).

![retrosmart-preview](https://raw.githubusercontent.com/mdomlop/retrosmart-x11-cursors/master/preview.gif "Retrosmart X11 cursor theme preview")

Retrosmart is a X11 cursor theme created for personal use. Inspired by old
Windows 3.x and OS X cursors, Retrosmart brings an old school feel to your
wobbly-windowed desktop of today.

It is available in white or black version, with or without alpha shading.

Installation
------------

For a system-wide installation run:

    $ make
    # make install

Alternatively you can build package versions for Debian and Arch Linux:

    $ make pkg_deb pkg_arch

Uninstallation
--------------

For uninstall run:

    # make uninstall


Dependencies
------------

For a successful compilation you need

- **rsvg-convert**: for generate PNGs from SVGs.
- **imagemagick**: for generate PNG versions with shadow.
- **xcursorgen**: for generate the cursors from the PNGs.


### You can test your cursors here: [Cursor tester](https://htmlpreview.github.io/?https://github.com/mdomlop/retrosmart-x11-cursors/blob/master/cursortest.html)


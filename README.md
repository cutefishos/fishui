# FishUI

FishUI is a GUI library based on QQC2 (Qt Quick Controls 2), every Cutefish application uses it.

## Features

* Light and Dark Mode
* Borderless Wayland window move & resize
* Blurred window
* Window shadow
* Desktop-level menu
* The style of the Qt Quick control
* ...

## Dependencies

```bash
sudo apt install qt6-base-dev qt6-base-private-dev qt6-declarative-dev -y
```

## Build
Before build, make sure you have necessary Qt environment.

```bash
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ..
make
sudo make install
```

## Packaging

### Debian/Ubuntu

Install compile dependencies:

```bash
$ sudo apt install equivs devscripts --no-install-recommends
$ sudo mk-build-deps -i -t "apt-get --yes" -r
```

Start packing

```bash
$ dpkg-buildpackage -b -uc -us
```

## License

FishUI is licensed under GPLv3.

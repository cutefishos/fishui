# FishUI

```bash
sudo apt install libqt5x11extras5-dev libkf5windowsystem-dev -y
```

## Build
Before build, make sure you have necessary Qt environment.

```bash
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ..
make
sudo make install
```
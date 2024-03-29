# Flounder

A **cross-platform** counter that can be used for the time-management in scientific talks.

![Language: Flutter](https://img.shields.io/badge/Language-Flutter/Dart-blue.svg?style=flat-square)
![Version: 1.2.4](https://img.shields.io/badge/Current_Version-1.2.4-green.svg?style=flat-square)

<img src="https://github.com/hep-mh/flounder/blob/main/assets/desktop-icon.png" alt="logo" width="300"/>

The above logo is based on [``this image``](https://imgbin.com/png/D3dzb0eY/turquoise-fish-png).

## How to use?

Home Page                                              |  Drawer
:-----------------------------------------------------:|:-----------------------------------------------------:
![](https://hep-mh.com/files/screenshots/usage_1.png)  |  ![](https://hep-mh.com/files/screenshots/usage_2.png)


Note that presets are persistent and do not get reset upon closing the application.


## How to install?

### • **Web** •

<img src="https://hep-mh.com/files/mimetypes/application-x-mswinurl.png" alt="web" width="70"/>

The web version of Flounder can be freely accessed at [``timer.hep-mh.com``](https://timer.hep-mh.com/). Feel free to use it on your platform of choice, as it works on mobile and desktop. In fact, Flounder even is a full-fledged PWA and can thus be installed as such.

*Alternatively, there also exist native versions for various platforms, which are discussed in the following:*

### • **Android** •

<img src="https://hep-mh.com/files/mimetypes/application-apk.png" alt="apk" width="70"/>

The ``.apk`` file for **arm | arm64 | x86_64 Android** can be downloaded from [here](https://hep-mh.com/files/packages/flounder/latest/flounder-latest-android.apk). After downloading, make sure to allow installation from unknown sources in your settings. And for your own security, turn it back off once you are done.

*Publication on F-Droid is on the Roadmap.*

### • **Linux** •

*ATTENTION: In the following, all commands involving``./`` assume that you are in the directory where the respective file is located.*

<img src="https://hep-mh.com/files/mimetypes/application-vnd.flatpak.png" alt="flatpak" width="70"/>

A ``.flatpak`` file for **arbitrary x86_64 Linux systems** can be downloaded from [here](https://hep-mh.com/files/packages/flounder/latest/flounder-latest-linux-x86_64.flatpak). After downloading, first install the flatpak for the Freedesktop platform via the command (also make sure that flatpak is correctly configured on your system. For more information, check [https://flatpak.org/setup/](https://flatpak.org/setup/).)
```
flatpak install org.freedesktop.Platform/x86_64/22.08
```
Afterwards, the previously downloaded package can be installed at user-level via
```
flatpak install --user ./flounder-latest-linux-x86_64.flatpak
```
(For installation at system-level, run with ``sudo`` and drop the ``--user`` flag). The application can then be started from your launcher or by typing the command
```
flatpak run com.hepmh.Flounder
```
into your terminal.

*Publication on Flathub is on the Roadmap.*

<details>

<summary> <b>Click here to show more installation options</b> </summary><br>

<img src="https://hep-mh.com/files/mimetypes/application-vnd.AppImage.png" alt="flatpak" width="70"/>

An ``.AppImage`` file for **arbitrary x86_64 Linux systems** can be downloaded from [here](https://hep-mh.com/files/packages/flounder/latest/flounder-latest-linux-x86_64.AppImage). After downloading, mark the file executable via the command
```
chmod 755 ./flounder-latest-linux-x86_64.AppImage
```
and run (on Wayland it is necessary to add ``GDK_BACKEND=x11`` before the command, since AppImages are currently not supported on Wayland)
```
./flounder-latest-linux-x86_64.AppImage
```
to start the application.

<img src="https://hep-mh.com/files/mimetypes/application-x-gzip.png" alt="targz" width="70"/>

A ``.tar.gz`` file with pre-combiled binaries for **x86_64 Debian/Ubuntu** can be downloaded from [here](https://hep-mh.com/files/packages/flounder/latest/flounder-latest-debian-x86_64.tar.gz). After downloading, unpack the file (preferably in a new directory) and run the command
```
./flounder
```
to start the application.

Note that this binary might also work on other platforms. But further testing is required. In case of doubt, use the flatpak or AppImage version above.

<img src="https://hep-mh.com/files/mimetypes/application-vnd.debian.binary-package.png" alt="flatpak" width="70"/>

A ``.deb`` file for **x86_64 Debian/Ubuntu** can be downloaded from [here](https://hep-mh.com/files/packages/flounder/latest/flounder-latest-debian-x86_64.deb). After downloading, install the package via the command
```
sudo apt install ./flounder-latest-debian-x86_64.deb
```
Afterwards, the application can be started from your launcher or by typing the command
```
flounder
```
into your terminal.

</details>

### • **Windows** •

<img src="https://hep-mh.com/files/mimetypes/application-x-msix.png" alt="msix" width="70"/>

A modern installer for **x86_64 Windows** in ``.msix`` format can be downloaded from [here](https://hep-mh.com/files/packages/flounder/latest/flounder-latest-windows-x86_64.msix). After downloading, double-click the file and proceed with the installation process. Afterwards, the application can be started from your launcher.

<details>

<summary> <b>Click here to show more installation options</b> </summary><br>

<img src="https://hep-mh.com/files/mimetypes/application-x-setup-exe.png" alt="exe" width="70"/>

A standard installer for **x86_64 Windows** in ``.exe`` format can be downloaded from [here](https://hep-mh.com/files/packages/flounder/latest/flounder-latest-windows-x86_64-setup.exe). After downloading, double-click the file and proceed with the installation process. Afterwards, the application can be started from your launcher.

<img src="https://hep-mh.com/files/mimetypes/application-x-zip.png" alt="zip" width="70"/>

A ``.zip`` file with pre-combiled binaries for **x86_64 Windows** can be downloaded from [here](https://hep-mh.com/files/packages/flounder/latest/flounder-latest-windows-x86_64.zip). After downloading, unpack the file (preferably in a new directory) and double-click on ``flounder.exe`` to start the application.

</details>

### • **ChromeOS** •

Go to [``timer.hep-mh.com``](https://timer.hep-mh.com/) and install the web version as a PWA (Progressive Web App) by clicking on the installation button in the right corner of the URL input field.

<details>

<summary> <b>Click here to show more installation options</b> </summary><br>

On Chromebooks with Linux support, any of the above Linux variants should also work.

</details>

### • **macOS** •

Coming soon...

### • **iOS/iPadOS** •

Since Apple currently does not allow sideloading on iOS (and I will not pay the money to upload it to the App Store), it does not make sense to provide a native iOS/iPadOS version here. Hence, on these platforms its best to use the web version. **Note however, that on these platforms, sound does not currently seem to work.**

Alternatively, you can, of course, always build it yourself!


## How to build?

Flounder is written in Dart using Flutter. Hence, in order to learn how to setup your build environment on your platform of choice and how to build basic executables for the different platforms, check out https://flutter.dev. For example, if you have a working build environment on Linux, a release build can be created via the command
```
flutter build linux --release
```
Similar commands are also available for other platforms. To get an idea for some of the commands, you may also want to take a look at the files in the ``build_scripts`` directory, which can be used to build for various platforms. These scripts also contain the relevant code to build Windows installer files, Flatpaks, AppImages, etc.

In general, it is possible to build applications for Android, iOS, Web, Linux, Windows, and macOS .

### Additional non-standard dependencies

1. Flounder depends on the [audioplayers](https://pub.dev/packages/audioplayers) package, which -- on Linux -- requires ``gstreamer``. For installation instructions, click [here](https://pub.dev/packages/audioplayers).

2. There also exist additional dependencies for building the various package formats with the provided build scripts, namely
  - ``flatpak-builder`` and `jsonnet` for building the *flatpak*
  - ``appimage-builder`` and ``gst-launch-1.0`` for building the *AppImage*
  - ``dpkg-deb`` for building the *debian package*, and
  - ``iscc`` for building the *Windows installer file*.

## Some history

<img src="https://hep-mh.com/files/mimetypes/application-x-java.png" alt="java" width="70"/>

The very first version of the timer was written in Java. If you are interested in how this version looked like, you can download it from [here](https://hep-mh.com/files/packages/flounder/counter-vintage-java.tar.gz). After downloading, extract the archive (preferably in a new directory) and run
```
java -jar counter.jar
```
This version should work on Linux/Windows/macOS, as long as a JavaVM is installed. However, this version will not get any new features in the future and has been completely abandoned in favour of Flounder.

# Flounder

A **cross-platform** counter that can be used for the time-management in scientific talks.

![Language: Flutter](https://img.shields.io/badge/Language-Flutter/Dart-blue.svg?style=flat-square)
![Version: 1.0.4](https://img.shields.io/badge/Current_Version-1.0.4-green.svg?style=flat-square)

<img src="https://github.com/hep-mh/flounder/blob/main/assets/desktop-icon.png" alt="logo" width="300"/>

The above logo is based on [``this image``](https://imgbin.com/png/D3dzb0eY/turquoise-fish-png).

## How to use?

Home Page                                             |  Drawer
:----------------------------------------------------:|:----------------------------------------------------:
![](https://hep-mh.com/files/screenshots/usage1.png)  |  ![](https://hep-mh.com/files/screenshots/usage2.png)


Note that presets are persistent and do not get reset upon closing the application.


## How to install?

### • **Web** •

<img src="https://hep-mh.com/files/mimetypes/application-x-mswinurl.png" alt="web" width="50"/>

The web version of Flounder can be freely accessed at [``timer.hep-mh.com``](https://timer.hep-mh.com/). Feel free to use it on your platform of choice, as it works on mobile and desktop. In fact, Flounder even is a full-fledged PWA and can thus be installed as such.

*Alternatively, there also exist native versions for various platforms, which are discussed in the following:*

### • **Android** •

<img src="https://hep-mh.com/files/mimetypes/application-apk.png" alt="apk" width="50"/>

The ``.apk`` file for Android can be downloaded from [here](https://hep-mh.com/files/packages/flounder-latest-android.apk). After downloading, make sure to allow installation from unknown sources in your settings. And for your own security, turn it back off once you are done.

*Publication on F-Droid is on the Roadmap.*

### • **Linux** •

*Provision of ``.deb`` and ``.AppImage`` packages/applications is on the Roadmap.*

<img src="https://hep-mh.com/files/mimetypes/application-x-gzip.png" alt="targz" width="50"/>

A ``.tar.gz`` file with pre-combiled binaries for x86_64 Debian/Ubuntu can be downloaded from [here](https://hep-mh.com/files/packages/flounder-latest-debian-x86_64.tar.gz). After downloading, unpack the file and run the command
```
./flounder
```
in the newly created directory to start the application.

Note that this binary might also work on other platform. But further testing is required. In case of doubt, use the flatpak version below.

<img src="https://hep-mh.com/files/mimetypes/application-vnd.flatpak.png" alt="flatpak" width="50"/>

A ``.flatpak`` file for arbitrary x86_64 Linux systems can be downloaded from [here](https://hep-mh.com/files/packages/flounder-latest-linux-x86_64.flatpak). After downloading, first install the flatpak for the Freedesktop platform via the command (also make sure that flatpak is correctly configured on your system. For more information, check [https://flatpak.org/setup/](https://flatpak.org/setup/).)
```
flatpak install org.freedesktop.Platform/x86_64/21.08
```
Afterwards, the previously downloaded package can be installed at user-level via
```
flatpak install --user flounder-latest-linux-x86_64.flatpak
```

*Publication on Flathub is on the Roadmap.*

### • **Windows** •

<img src="https://hep-mh.com/files/mimetypes/application-x-zip.png" alt="zip" width="50"/>

A ``.zip`` file with pre-combiled binaries for x86_64 Windows 7/8/10/11 can be downloaded from [here](https://hep-mh.com/files/packages/flounder-latest-windows-x86_64.zip). After downloading, unpack the file and double-click on ``flounder.exe`` in the previously created directory to start the application. 

<img src="https://hep-mh.com/files/mimetypes/application-x-desktop.png" alt="exe" width="50"/>

A standard installer in ``.exe`` format can be downloaded from [here](https://hep-mh.com/files/packages/flounder-latest-windows-x86_64-setup.exe). After downloading, double-click the file and proceed with the installation process.

### • **macOS / iOS** •

Currently, there do not exist any builds for macOS and iOS, as I lack access to a macOS device, which is needed to build for these platforms. There might be a native version for macOS in the future, but since Apple does not allow sideloading on iOS (and I will not pay the money to upload it to the App Store), the future looks a lot less promising for iOS. **However, even on these platforms, you can always use the web version.**


## How to build?

Flounder is written in Dart using Flutter. Hence, in order to learn how to setup your build environment on your platform of choice and how to build basic executables for the different platforms, check out https://flutter.dev. For example, if you have a working build environment on Linux, a release build can be created via the command
```
flutter build linux --release
```
Similar commands are also available for other platforms. To get an idea for some of the commands, you may also want to take a look at the files ``build-main.sh`` and ``build-windows.ps1``, which can be used to build for Linux/Android on Linux and for Windows on Windows, respectively. These scripts also contain the relevant code to build Windows installer files, flatpaks, etc.

In principle, it is possible to build applications for Android, iOS, Web, Linux, Windows, and macOS 

## Some history

<img src="https://hep-mh.com/files/mimetypes/application-x-java.png" alt="java" width="50"/>

The very first version of the timer was written in Java. If you are interested in how this version looked like, you can download it from [here](https://hep-mh.com/files/packages/counter-vintage-java.tar.gz). After downloading, extract the archive and run
```
java -jar counter.jar
```
in the created directory. This version should work on Linux/Windows/macOS, as long as a JavaVM is installed. However, this version will not get any new features in the furture and has been completely abandoned in favour of Flounder.

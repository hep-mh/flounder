# Flounder

A **cross-platform** counter that can be used for the time-management in scientific talks.

![Language: Flutter](https://img.shields.io/badge/Language-Flutter/Dart-blue.svg?style=flat-square)
![Version: 1.0.4](https://img.shields.io/badge/Current_Version-1.0.4-green.svg?style=flat-square)

<img src="https://github.com/hep-mh/flounder/blob/main/assets/desktop-icon.png" alt="logo" width="300"/>

The above logo is based on [``this image``](https://imgbin.com/png/D3dzb0eY/turquoise-fish-png).

## Installation & Usage

<img src="https://hep-mh.com/files/mimetypes/application-x-mswinurl.png" alt="web" width="50"/>

The web version of Flounder can be freely accessed at [``timer.hep-mh.com``](https://timer.hep-mh.com/). Feel free to use it on your platform of choice, as it works on mobile and desktop. In fact, Flounder even is a full-fledged PWA and can thus be installed as such.

*Alternatively, there also exist native versions for various platforms, which are discussed in the following:*

### • **Android** •

<img src="https://hep-mh.com/files/mimetypes/application-apk.png" alt="apk" width="50"/>

The ``.apk`` file for Android can be downloaded [here](https://hep-mh.com/files/packages/flounder-latest-android.apk). After downloading, make sure to allow installation form unknown sources in your settings. And for your own security, turn it back off once you are done.

*Publication on F-Droid is on the Roadmap.*

### • **Linux** •

<img src="https://hep-mh.com/files/mimetypes/application-x-gzip.png" alt="targz" width="50"/>

A ``.tar.gz`` files with precombiled binaries for x86_64 Debian/Ubuntu can be downloaded [here](https://hep-mh.com/files/packages/flounder-latest-debian-x86_64.tar.gz). After downloading, unpack the file and run the command
```
./flounder
```
in the newly created directory.

<img src="https://hep-mh.com/files/mimetypes/application-vnd.flatpak.png" alt="flatpak" width="50"/>

A ``.flatpak`` file for any x86_64 Linux system can be downloaded [here](https://hep-mh.com/files/packages/flounder-latest-linux-x86_64.flatpak). After downloading, first install the Freedesktop platform via the command (also make sure that flatpak is currently configured on your system. For more information, check [https://flatpak.org/setup/](https://flatpak.org/setup/).)
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

A ``.zip`` files with precombiled binaries for x86_64 Windows 7/9/10/11 can be downloaded [here](https://hep-mh.com/files/packages/flounder-latest-windows-x86_64.zip). After downloading, unpack the file and double-click on ``flounder.exe`` in the previously created directory. 

<img src="https://hep-mh.com/files/mimetypes/application-x-desktop.png" alt="exe" width="50"/>

A standard installer in ``.exe`` format can be downloaded [here](https://hep-mh.com/files/packages/flounder-latest-windows-x86_64-setup.exe). After downloading, double-click the file and proceed with the installation process.

### • **macOS/iOS** •

Currently, there do not exist any builds for macOS and  iOS, as I simply lack access to a macOS device, which is needed to build for these platforms. There might be a native version for macOS in the future, but since Apple does not allow sideloading on iOS (and I will not pay the money to upload it to the App Store), the future looks a lot less promising for iOS. **However, even on these platforms, you can simply use the web version.**

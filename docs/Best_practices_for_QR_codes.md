# Best practices for QR codes

- [Introduction](#introduction)
- [Color](#color)
- [Size](#size)
- [Low light](#low-light)
- [Privacy](#privacy)
  - [Snapshot](#snapshot)
  - [Screenshot](#screenshot)
  - [Screen recording](#screen-recording)

## Introduction

Showing and scanning QR codes is an key feature of the CoronaCheck apps. These are some of the best practices handling, reading and displaying QR codes. The code and technical documentation of the QR code generation of the CoronaCheck apps is located in the [iOS module](https://github.com/minvws/nl-rdo-app-ios-modules/blob/main/Sources/QRGenerator/QRGenerator.md) and [Android module](https://github.com/minvws/nl-rdo-app-android-modules/blob/main/modules/qrgenerator/README.md).

## Color

It is possible to create all sort of fancy colored QR codes, however older devices often do not recognize the QR code. Scanning a black QR code on a white background performs the best on most devices.

## Size

The preferred size of the QR code is as big as possible. Show the QR code as square image with the full width of the device, with a small margin on all sides.

## Low light

To aid scanning all situations, the best contrast is obtained by setting the device to 100% brightness. After leaving the QR code view, the brightness level should be restored.

- On iOS see [`UIScreen.main.brightness`](https://developer.apple.com/documentation/uikit/uiscreen/1617830-brightness) and use `CGFLoat 100`,
- On Android see [`WindowManager.LayoutParams.screenBrightness`](https://developer.android.com/reference/android/view/WindowManager.LayoutParams#screenBrightness) and use `BRIGHTNESS_OVERRIDE_FULL`.

## Privacy

A QR code might contain valuable or privacy sensitive data. To prevent data loss and to prevent copying a QR, these three measures are recommended.

- All three privacy measures are set on Android with the [`WindowManager.LayoutParams.FLAG_SECURE`](https://developer.android.com/reference/android/view/WindowManager.LayoutParams#FLAG_SECURE) flag.

### Snapshot

When an app is pushed to the background and is available through the task manager / app switcher, a screenshot is created to help the user identify the app. These snapshots might even be stored on disk and be accessible for malicious use.

- For iOS observe the [`UIApplication.willResignActiveNotification`](https://developer.apple.com/documentation/uikit/uiapplication/1622973-willresignactivenotification) notification and create a new top level UIWindow with the designed snapshot viewController as the rootViewController. Remove that window when a [`UIApplication.didBecomeActiveNotification`](https://developer.apple.com/documentation/uikit/uiapplication/1622953-didbecomeactivenotification) is received.

### Screenshot

Disable taking a screenshot to prevent copying a QR code.

- On iOS you only can get a [`UIApplication.userDidTakeScreenshotNotification`](https://developer.apple.com/documentation/uikit/uiapplication/1622966-userdidtakescreenshotnotificatio) **after** a screenshot has been made.

### Screen recording

Disable screen recording to prevent copying a QR code.

- In iOS you must observe the [`UIScreen.capturedDidChangeNotification`](https://developer.apple.com/documentation/uikit/uiscreen/2921652-captureddidchangenotification) notification, inspect the [`UIScreen.main.isCaptured`](https://developer.apple.com/documentation/uikit/uiscreen/2921651-iscaptured) property and hide the QR code in the view.

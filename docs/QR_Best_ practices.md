# QR Best practices

1. [Introduction](#Introduction)
2. [Color](#Color)
3. [Size](#Size)
4. [Low light](#Low-Light)
5. [Privacy](#Privacy)

## Introduction

We have been showing and reading QR's in the CoronaCheck apps for (over) two years now. These are some of the best practices handling, reading and displaying QR's.

## Color 

This is a simple one. Black QR on a white background. You can create all sort of fancy colored QR's, but scanning a black QR on a white background performs the best. Some of the newer phones have no problem with the colored stuff, older devices don't recognize the QR.

## Size

Again, very simple, the preferred size is as big as possible. We try to create a square image with the full width of the device, with a 20 px margin on all sides. 

## Low light

To aid scanning in low light situation, i.e. an alley for a club entrance, and also in direct sun light, we found that the best contrast is obtained by setting the brightness of the device to 100% brightness. We try to restore the previous user preferred brightness when leaving the QR view. 

For iOS see [UIScreen.main.brightness](https://developer.apple.com/documentation/uikit/uiscreen/1617830-brightness) and use `CGFLoat 100`, for Android: [WindowManager.layoutParams.screenBrightness](https://developer.android.com/reference/android/view/WindowManager.LayoutParams#screenBrightness) and use `WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_FULL`

## Privacy

A QR might contain valuable or privacy sensitive data. To prevent data loss and to prevent copying a QR, we recommend these three measures:

### Snapshot

Whenever an app is pushed to the background and is available through the task manager / app switcher, a screenshot is created to help the user identify the app. These snapshots might even be stored on disk and be accessible for malicious use. 

For iOS observe the [UIApplication.willResignActiveNotification](https://developer.apple.com/documentation/uikit/uiapplication/1622973-willresignactivenotification) notification and create a new top level UIWindow with the designed snapshot viewController as the rootViewController. Remove that window when you receive a [UIApplication.didBecomeActiveNotification](https://developer.apple.com/documentation/uikit/uiapplication/1622953-didbecomeactivenotification).

### Screenshot

To prevent copying a QR you can disable taking a screenshot. Unfortunately, this is Android only by setting the [WindowManager.LayoutParams.FLAG_SECURE](https://developer.android.com/reference/android/view/WindowManager.LayoutParams#FLAG_SECURE) flag. For iOS you only can get a [UIApplication.userDidTakeScreenshotNotification](https://developer.apple.com/documentation/uikit/uiapplication/1622966-userdidtakescreenshotnotificatio) **after** a screenshot has been made. 

### Screen recording

Prevending recording the QR page is possible in both iOS and Android. In Android you must set the [WindowManager.LayoutParams.FLAG_SECURE](https://developer.android.com/reference/android/view/WindowManager.LayoutParams#FLAG_SECURE) flag. In iOS you must observe the [UIScreen.capturedDidChangeNotification](https://developer.apple.com/documentation/uikit/uiscreen/2921652-captureddidchangenotification) notification, inspect the [UIScreen.main.isCaptured](https://developer.apple.com/documentation/uikit/uiscreen/2921651-iscaptured) property and hide the QR your self.  
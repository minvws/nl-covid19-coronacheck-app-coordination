# Distribution

The CoronaCheck and CoronaCheck Scanner apps are distributed via various methods.

## Source form

Both the Android and iOS apps are available in source code form from GitHub:

* Android source code for CoronaCheck and Scanner for CoronaCheck: https://github.com/minvws/nl-covid19-coronacheck-app-android 
* iOS source code for CoronaCheck and Scanner for CoronaCheck: https://github.com/minvws/nl-covid19-coronacheck-app-ios

There are tags in each repository corresponding to releases from the stores. The public repository might lag behind a few days but generally should be up to date whenever a new release is done to the app stores.

To validate that the source versions and the store binaries are based on the same source code, we have a notarize build process in place. The notary statements can be found in our [provenance repository](https://github.com/minvws/nl-covid19-coronacheck-app-provenance)

## Apple App Store

In the Apple App Store we publish the binaries for the CoronaCheck and Scanner for CoronaCheck apps:

* CoronaCheck: https://apps.apple.com/nl/app/coronacheck/id1548269870
* Scanner for CoronaCheck: https://apps.apple.com/nl/app/scanner-voor-coronacheck/id1549842661

## Google Play Store

In the Google Play Store we publish the binaries for the CoronaCheck and Scanner for CoronaCheck apps:

* CoronaCheck: https://play.google.com/store/apps/details?id=nl.rijksoverheid.ctr.holder&hl=nl&gl=US
* Scanner for CoronaCheck: https://play.google.com/store/apps/details?id=nl.rijksoverheid.ctr.verifier&hl=nl&gl=US

## F-Droid Store

We are currently investigating the possibility of offering an official build of the CoronaCheck app for the F-Droid store.

## APK file

For the CoronaCheck Scanner we provide an APK file that can be loaded on verifier devices using MDM tooling or other bulk distribution mechanisms.

* CoronaCheck Scanner APK: https://coronacheck.nl/nl/faq-scanner/2-6-kan-ik-een-apk-bestand-downloaden/

Note that the link always points to the latest APK. Since we cannot provide an auto-update mechanism for manual APKs, users of this APK are encouraged to regulary maually update the APK on their devices. (In the case of a forced upgrade, the app will point the user to the app store, so you'll have to manually upgrade the APK).


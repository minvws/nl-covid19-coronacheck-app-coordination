# COVID-19 CoronaCheck App Documentation

## Introduction
To streamline development of both the iOS and the Android app, we came up with a naming convention for each scene.

## Launch
During **Launch** the remote configuration is fetched. This can result in various states: **AppStatus**

Launch | AppStatus (End Of Life)
--|--
![Launch](images/launch.png)| ![AppStatus (End Of Life)](images/end-of-life.png)
AppStatus (No Internet) | AppStatus (Required Update)
![AppStatus (No Internet)](images/no-internet.png)| ![AppStatus (Required Update)](images/required-update.png)

## Onboarding
First time users are treated with an onboarding: **OnboardingItem** and **PrivacyConsent**

OnboardingItem | PrivacyConsent
--|--
![OnboardingItem](images/onboarding-item.png)| ![PrivacyConsent](images/privacy-consent.png)
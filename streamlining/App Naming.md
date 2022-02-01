# COVID-19 CoronaCheck App Documentation

## Introduction
To streamline development of both the iOS and the Android app, we came up with a naming convention for each scene.

## Launch
During **Launch** the remote configuration is fetched. This can result in various states: **AppStatus**

Launch | App Status (End Of Life)
--|--
![Launch](images/launch.png)| ![AppStatus (End Of Life)](images/end-of-life.png)
App Status (No Internet) | App Status (Required Update)
![AppStatus (No Internet)](images/no-internet.png)| ![AppStatus (Required Update)](images/required-update.png)

## Onboarding
First time users are treated with an onboarding: **OnboardingItem** and **PrivacyConsent**

Onboarding Item | Privacy Consent
--|--
![OnboardingItem](images/onboarding-item.png)| ![PrivacyConsent](images/privacy-consent.png)

## NewFeatures
New features in the app are displayed once to the user: **NewFeature** and **NewConsent**

New Feature | NewConsent
--|--
![NewFeature](images/onboarding-item.png)| n/a

## Dashboard
The **Dashboard** is the place for the domestic and international GreenCards.

Dashboard (Empty) | Dashboard (With Card)
--|--
![Dashboard (Empty)](images/dashboard-empty.png)| ![Dashboard (With Card)](images/dashboard-greencard.png)

## ShowQR
The QR from the greencards will be shown on **ShowQR**, the details of the international QR are handled by the **DCCQRDetails**

Show QR | DCC QR Details
--|--
![ShowQR](images/show-qr.png)| ![DCCQRDetails](images/dcc-qr-details.png)

## Menu
The **Menu** is the main navigation router. You can also find the **AboutThisApp** here. 
Menu | About This App
--|--
![Menu](images/menu.png)| ![About this app](images/about-this-app.png)

## Add Negative Test
When adding a negative test QR, the first scene will be **ChooseProofType**, followed by **ChooseTestLocation**.
A token and a verification code can be entered in the **InputRetrievalCode**, the negative test is displayed in the **ListRemoteEvents** with details in the **RemoteEventDetails**

Choose Proof Type | Choose Test Location
--|--
![Choose Proof Type](images/choose-proof-type.png)| ![Choose Test Location](images/choose-test-location.png)
Input Retrieval Code| Choose Test Location
![Input Retrieval Code](images/input-retrieval-code.png)| ![List Remote Events](images/list-remote-events.png)
Remote Event Details | 
![Remote Event Details ](images/remote-event-details.png)| 


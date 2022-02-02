# COVID-19 CoronaCheck App Documentation

## Introduction
To streamline development of both the iOS and the Android app, we came up with a naming convention for each scene.

## Holder
1. [Launch](#launch)
2. [Onboarding](#onboarding)
3. [New Features](#new-features)
4. [Dashboard](#dashboard)
5. [Show QR](#show-qr)
6. [Menu](#Menu)
7. [Add Commercial Negative Test](#add-commercial-negative-test)
8. [Add GGD Negative Test / Vaccination / Recovery](#add-ggd-negative-test--vaccination--recovery)
9. [Add Visitor Pass](#add-visitor-pass)
10. [Add Paper Proof](#add-paper-proof)

### Launch
During **Launch** the remote configuration is fetched. This can result in various states: **AppStatus**

Launch | App Status (End Of Life)
--|--
![Launch](images/launch.png)| ![AppStatus (End Of Life)](images/end-of-life.png)
App Status (No Internet) | App Status (Required Update)
![AppStatus (No Internet)](images/no-internet.png)| ![AppStatus (Required Update)](images/required-update.png)

### Onboarding
First time users are treated with an onboarding: **OnboardingItem** and **PrivacyConsent**

Onboarding Item | Privacy Consent
--|--
![OnboardingItem](images/onboarding-item.png)| ![PrivacyConsent](images/privacy-consent.png)

### New Features
New features in the app are displayed once to the user: **NewFeature** and **NewConsent**

New Feature | NewConsent
--|--
![NewFeature](images/onboarding-item.png)| n/a

### Dashboard
The **Dashboard** is the place for the domestic and international GreenCards.

Dashboard (Empty) | Dashboard (With Card)
--|--
![Dashboard (Empty)](images/dashboard-empty.png)| ![Dashboard (With Card)](images/dashboard-greencard.png)

### Show QR
The QR from the greencards will be shown on **ShowQR**, the details of the international QR are handled by the **DCCQRDetails**

Show QR | DCC QR Details
--|--
![ShowQR](images/show-qr.png)| ![DCCQRDetails](images/dcc-qr-details.png)

### Menu
The **Menu** is the main navigation router. You can also find the **AboutThisApp** here. 
Menu | About This App
--|--
![Menu](images/menu.png)| ![About this app](images/about-this-app.png)

### Add Commercial Negative Test
When adding a negative test QR, the first scene will be **ChooseProofType**, followed by **ChooseTestLocation**.
A token and a verification code can be entered in the **InputRetrievalCode**, the negative test is displayed in the **ListRemoteEvents** with details in the **RemoteEventDetails**

Choose Proof Type | Choose Test Location
--|--
![Choose Proof Type](images/choose-proof-type.png)| ![Choose Test Location](images/choose-test-location.png)
Input Retrieval Code| List Remote Events
![Input Retrieval Code](images/input-retrieval-code.png)| ![List Remote Events](images/list-remote-events.png)
Remote Event Details | 
![Remote Event Details ](images/remote-event-details.png)| 

### Add GGD Negative Test / Vaccination / Recovery
All of the non commercial flows for negative test / vaccination / recovery, start with the **ChooseProofType**, followed by **StartRemoteEvent**. The events are fetched in **FetchRemoteEvents** The rest of the flow is identical to the commercial flow with **ListRemoteEvents** and **RemoteEventDetails**
Choose Proof Type | Remote Event Start
--|--
![Choose Proof Type](images/choose-proof-type.png)| ![Remote Event Start](images/remote-event-start.png)
Fetch Remote Events| List Remote Events
![Fetch Remote Events](images/fetch-remote-events.png)| ![List Remote Events](images/list-remote-events-vaccination.png)
Remote Event Details | 
![Remote Event Details ](images/remote-event-details-vaccination.png)| 

### Add Visitor Pass
Through the menu you start the application for a visitor pass **VisitorPassStart**. This is the same flow as the commercial negative test with the **InputRetrievalCode**, **ListRemoteEvents** and the **RemoteEventDetails**. When only the assessment part is finished, a banner on the dashboard will lead to **VisitorPassCompleteCertificate** to complete the visitor pass.

Visitor Pass Start | Choose Test Location
--|--
![Visitor Pass Start](images/visitor-pass-start.png)| ![Input Retrieval Code](images/input-retrieval-code-visitor-pass.png)
 List Remote Events| LRemote Event Details 
![List Remote Events](images/list-remote-events-visitor-pass.png)|![Remote Event Details](images/remote-event-details-visitor-pass.png)
Visitor Pass Complete Certificate |
![Visitor Pass Complete Certificate](images/visitor-pass-complete-certificate.png)

### Add Paper Proof
Through the menu you can start the paper proof flow: **PaperProofStart**, **PaperProofInputCouplingCode**, **PaperProofStartScanning**, **PaperProofScan**, **PaperProofCheck**, to end up with the normal flow: **ListRemoteEvents** and the **RemoteEventDetails**.

Paper Proof Start | Paper Proof Input Coupling Code
--|--
![Paper Proof Start](images/paper-proof-start.png) | ![Paper Proof Input Coupling Code](images/paper-proof-input-coupling-code.png)
Paper Proof Start Scanning | Paper Proof Scan
![Paper Proof Start Scanning](images/paper-proof-start-scanning.png) | ![Paper Proof Scan](images/paper-proof-scan.png)
Paper Proof Check | List Remote Events
![Paper Proof Check ](images/paper-proof-check.png)| ![List Remote Events](images/list-remote-events-paper-proof.png)
Remote Event Details | 
![Remote Event Details ](images/remote-event-details-paper-proof.png)| 


## Verifier

1. [Start Scanning](#start-scanning)
2. [Scan Instructions](#scan-instructions)
3. [Risk Setting](#risk-setting)
4. [Verifier Scan](#verifier-scan)
5. [Verifier Result](#verifier-result)
6. [Scan Log](#scan-log)

### Start Scanning
The verifier start scene is **StartScanning** 
Start Scanning | Start Scanning (3G)
--|--
![Start Scanning](images/start-scanning.png) | ![Start Scanning 3G](images/start-scanning-3G.png)
Start Scanning (Switch to 1G) | Start Scanning (Switch to 3G)
![Start Scanning (Switch to 1G)](images/start-scanning-to-1G.png) | ![Start Scanning (Switch to 3G)](images/start-scanning-to-3G.png)
Start Scanning (1G) | 
![Start Scanning 1G](images/start-scanning-1G.png) |

### Scan Instructions
All the instructions are **ScanInstructions** and **PolicyInformation**
Scan Instructions | Policy Information
--|--
![Start Scanning](images/scan-instructions.png) | ![Policy Information](images/policy-information.png)

#### Risk Setting
To select a policy, use **RiskSetting**
Risk Settings Start | Risk Setting
--|--
![Risk Settings Start](images/risk-setting-start.png) | ![Risk Setting](images/risk-setting.png)

#### Verifier Scan
Scanning in the verifier is handled by the **VerifierScan**
Verifier Scan | -
--|--
![Verifier Scan](images/scan.png) |

### Verifier Result
todo

### Scan Log
An overview of the scans can be found in **ScanLog**
Scan Log Empty | Scan Log
--|--
![Scan Log Empty](images/scan-log-empty.png) | ![Scan Log](images/scan-log.png)
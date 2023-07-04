# App Configuration Values

This document provides an overview of the configuration values that the CoronaCheck apps use.

## Holder app

Setting | Example | Description | Apps | Web | Depre<br/>cated?
-|-|-|-|-|-
`androidMinimumVersion`| 2137 |The mininum version (build number) that an Android user should have. If the user has a version smaller than this, they can't use the app until they upgrade.|Yes|No|
`androidRecommendedVersion`| 2137 |The recommended version (build number) that an Android user should have. If the user has a version smaller than this, they get a pop-up telling them they can upgrade via the store.|Yes|No|
`androidMinimumVersionMessage`| "Om de app te gebruiken heb<br/> je de laatste versie uit de store nodig." |The message that the user will see if they don't have the minimum required version|Yes|No|
`iosMinimumVersion`| "2.3.1" |The mininum version that an iOS user should have. If the user has a version smaller than this, they can't use the app until they upgrade.|Yes|No|
`iosRecommendedVersion`| "2.3.1" |The recommended version that an iOS user should have. If the user has a version smaller than this, they get a pop-up telling them they can upgrade via the store.|Yes|No|
`iosMinimumVersionMessage`| "Om de app te gebruiken heb<br/>je de laatste versie uit de store nodig." |The message that the user will see if they don't have the minimum required version|Yes|No|
`iosAppStoreURL`| "https://apps.apple.com/nl/<br/>app/coronacheck/id1548269870" |The url of the app in the app store. The user will be directed here for upgrades.|Yes|No|
`appDeactivated`| false |The 'kill switch'. If this setting is set to true, the app will disable itself and not allow the user to use it.|Yes|?|
`configTTL`| 2419200 |The 'time to live' (in seconds) tells the app how old a configuration may be. If the app has no way to refresh the config and the config is older than this, the user will get a message telling them to go online first.|Yes|?|
`configMinimumIntervalSeconds`| 43200 |The minimum amount of seconds that must be between two config fetches. The app will opportunistically refresh its config when you open it and there's a connection, unless the config was fetched less than this amount of seconds ago.|Yes|?|
`upgradeRecommendationInterval`| 24 |This one is used to only show the recommended upgrade popup once every upgradeRecommendationInterval hours|Yes|No|No
`maxValidityHours`| 24 |Deprecated way to specify validity in hours. Is no longer used.|No|No|Yes
`informationURL`| "https://coronacheck.nl" |Deprecated, used to indicate the url of the CoronaCheck website. This info is now taken from the translation tool.|No|No|Yes
`requireUpdateBefore`| 1620781181 |This value was added for future use but was never actually implemented. The idea was: If there's a required upgrade, this setting indicates by when the user should upgrade. If this is in the future, then the message telling the user their app is too old will be postponed until this moment, and they will only get a warning first|No|No|Yes
`ggdEnabled`| true |When this is enabled, the user is presented with a selection screen to select testing GGD or other locations. When this is disabled, the user is directly taken to the other locations|Yes|No|No
`euLaunchDate`| "2021-06-30T22:00:00Z" |The date the EU DCC goes into effect. If the app is started before this date, a countdown to the EU Launch Date is shown|No|No|Yes
`recoveryGreencardRevised-`<br/>`ValidityLaunchDate`| "2021-11-04T22:00:00Z" |When recovery cards validity is changed, this date will tell the app when that change will go into effect.|Yes|?|
`temporarilyDisabled`| false |This was intended for future use but was not yet implemented. The idea was that the setting can tenporarily disable the app. Unlinke the kill switch (`appDeactivated`) this is temporary and the message telling the user that the app is disabled will reflect that.|No|No|Yes
`vaccinationEventValidity`| 14600 |How long (in hours) a vaccination event will be stored in the app. It will be deleted if it's older than this.|Yes|No|?
`vaccinationEventValidityDays`| 730 |?|?|?|?
`recoveryEventValidity`| 8760 |How long (in hours) a recovery event will be stored in the app. It will be deleted if it's older than this.|Yes|?|?
`recoveryEventValidityDays`| 365 |?|?|?|?
`recoveryExpirationDays`| 180 |How long (in days) a recovery QR will remain valid. The app will show the user when their recovery expires, based on this.|Yes|?|
`testEventValidity`| 96 |How long (in hours) a test event will be stores in the app. It will be deleted if it's older than this|?|?|Yes
`testEventValidityHours`| 96 |How long (in hours) a test event will be stores in the app. It will be deleted if it's older than this|?|?|
`domesticCredentialValidity`| 24 |How long a domestic QR will be valid. (Strippenkaart model strip size)|Yes|No|
`credentialRenewalDays`| 8 |The amount of days that the app will try to proactively refresh strippen, before the last 'strip' expires.|Yes|No|
`clockDeviationThresholdSeconds`| 30 |The allowed amount of skew a device clock is allowed to have before showing a warning to the user that their time is wrong.|Yes|No|
`domesticQRRefreshSeconds`| 30 |How often a QR code in the app is refreshed |Yes|No|-
`internationalQRRelevancyDays`| 28 |This amount of days after a vaccination was applied, a DCC becomes the most relevant (default)card. If a vaccination (e.g. the final in a series) was applied more recent than this, the app will promote the previous DCC as the most relevant (as it will be valid in more countries)|Yes|?|
`luhnCheckEnabled`| false |Whether or not a client side LUHN check is applied to test result retrieval tokens to have early warning of copy/paste/typo errors by the user.|Yes|Yes|
`euTestResults`| `[{ "code":"260415000", "name": "Negatief (geen corona)"} ]`|A mapping of EU valueset codes to a human readable string for test results.|Yes|Yes|
`hpkCodes`| `[{"code": "2924528", "name": "Pfizer (Comirnaty)", "vp": "1119349007", "mp": "EU/1/20/1528", "ma": "ORG-100030215"}]` |A mapping of NL vaccination codes to a human readable string for vaccinations |Yes|Yes|
`euBrands`| `[{"code": "EU/1/20/1528", "name": "Pfizer (Comirnaty)"}]` |A mapping of EU valueset codes to a human readable string for vaccination brands|Yes|Yes|
`nlTestTypes`| `[{"code": "pcr", "name": "PCR Test"}]`|A mapping of test provider 2.0 test types to a human readable string |?|?|Yes
`euVaccinations`| `[{"code": "1119349007", "name": "SARS-CoV-2 mRNA vaccine"}` |A mapping of EU valueset codes to a human readable string for vaccination prophylaxis|Yes|Yes|
`euManufacturers`| `[{"code": "ORG-100001699", "name": "AstraZeneca AB"}]` |A mapping of EU valueset codes to a human readable string for vaccine manufacturers|Yes|Yes|
`providerIdentifiers`| `[{ "name": "CTP-TEST-MVWS", "code": "ZZZ"}]`|A mapping of provider prefix codes for test results to a name|?|?|
`universalLinkDomains`| `[{"url": "downloadclose.com","name": "Close app"}]`|The allow-list of domains that universal links can use as valid return urls|Yes|No|

 

## Verifier app

Setting | Example | Description | Depre<br/>cated?
-|-|-|-
`androidMinimumVersion`| 2522|The mininum version (build number) that an Android user should have. If the user has a version smaller than this, they can't use the app until they upgrade.|
`androidRecommendedVersion`| 2522|The recommended version (build number) that an Android user should have. If the user has a version smaller than this, they get a pop-up telling them they can upgrade via the store.|
`androidMinimumVersionMessage`| "Om de app te gebruiken heb je de laatste versie uit de store nodig."|The message that the user will see if they don't have the minimum required version|?
`playStoreURL`| "https://play.google.com/store/apps/<br/>details?id=nl.rijksoverheid.ctr.verifier"|The url of the app in the play store. The user will be directed here for upgrades.|
`iosMinimumVersion`| "2.4.1"|The mininum version that an iOS user should have. If the user has a version smaller than this, they can't use the app until they upgrade.|
`iosRecommendedVersion`| "2.4.1"|The recommended version that an iOS user should have. If the user has a version smaller than this, they get a pop-up telling them they can upgrade via the store.|
`iosMinimumVersionMessage`| "Om de app te gebruiken heb je de laatste versie uit de store nodig."|The message that the user will see if they don't have the minimum required version|?
`iosAppStoreURL`| "https://apps.apple.com/nl/app/<br/>scanner-voor-coronacheck/id1549842661"|The url of the app in the app store. The user will be directed here for upgrades.|
`appDeactivated`| false|The 'kill switch'. If this setting is set to true, the app will disable itself and not allow the user to use it.|
`configTTL`| 86400|The 'time to live' (in seconds) tells the app how old a configuration may be. If the app has no way to refresh the config and the config is older than this, the user will get a message telling them to go online first.|-
`configMinimumIntervalSeconds`| 3600|The minimum amount of seconds that must be between two config fetches. The app will opportunistically refresh its config when you open it and there's a connection, unless the config was fetched less than this amount of seconds ago|
`upgradeRecommendationInterval`| 24|?|-
`maxValidityHours`| 40|?|-
`clockDeviationThresholdSeconds`| 30|The allowed amount of skew a device clock is allowed to have before showing a warning to the user that their time is wrong.|-
`informationURL`| "https://coronacheck.nl"|The url of the CoronaCheck website. 'More info' buttons will link here.|
`defaultEvent`| "cce4158f-582f-49c0-9d4d-611ce3866999"|?|Yes
`universalLinkDomains`| `[{ "url": "coronacheck.nl", "name":"CoronaCheck app"}]`|The allow-list of domains that universal links can use as valid return urls|
`domesticVerificationRules.`<br/>`qrValidForSeconds` | 60|The validity of an app QR. After this amount of seconds, a QR shown from the app is no longer valid.|
`domesticVerificationRules.`<br/>`proofIdentifierDenylist`| `{ "JyoXN+LkbWEjqBvte11m8w==": true }`|A deny-list of QR codes that is deemed invalid (typically based on fraudulent distributrion).|
`europeanVerificationRules.`<br/>`testAllowedTypes`| `["LP217198-3"]`|List of DCC test types that are accepted|
`europeanVerificationRules.`<br/>`testValidityHours`| 25|The validity of DCC test results. AFter this amount of hours a DCC will no longer lead to a green checkmark|
`europeanVerificationRules.`<br/>`vaccinationValidityDelay`<br/>`BasedOnVaccinationDate`| true|Whether or not waiting times should be applied to vaccinations.|
`europeanVerificationRules.`<br/>`vaccinationValidityDelay`<br/>`IntoForceDate`| "2021-07-10"|The date that the previous setting goes into effect|
`europeanVerificationRules.`<br/>`vaccinationValidityDelayDays`| 14|The amount of days ago that a vaccination must have been applied to get a green checkmark |
`europeanVerificationRules.`<br/>`vaccinationJanssen`<br/>`ValidityDelayDays`| 28|The amount of days ago that a Janssen vaccination must have been applied to get a green checkmark.|
`europeanVerificationRules.`<br/>`vaccinationJanssen`<br/>`ValidityDelayIntoForceDate`| "2021-08-14"|The date that the previous setting goes into effect|
`europeanVerificationRules.`<br/>`vaccineAllowedProducts`| `["EU/1/20/1528"]`|A list of EU DCC vaccinations that lead to a green checkmark|
`europeanVerificationRules.`<br/>`recoveryValidFromDays`| 11|Recovery DCCs will only scan green if the sampledate is more than this amount of days ago|
`europeanVerificationRules.`<br/>`recoveryValidUntilDays`| 180|Recover DCCs will only scan green if the sampldate is no more than this amount of days ago|
`europeanVerificationRules.`<br/>`proofIdentifierDenylist` | `{"q5TKp3sKMWlVjmMUGdhTtw==`| true}`|A deny-list of QR codes that is deemed invalid (typically based on fraudulent distributrion).|


# App Configuration Values

This document provides an overview of the configuration values that the CoronaCheck apps use.

## Holder app

Setting | Example | Description | Android/iOS | Web | Deprecated?
-|-|-|-|-|-
`androidMinimumVersion`| 2137 |-|-|-|-
`androidRecommendedVersion`| 2137 |-|-|-|-
`androidMinimumVersionMessage`| "Om de app te gebruiken heb je de laatste versie uit de store nodig." |-|-|-|-
`playStoreURL`| "https://play.google.com/store/apps/details?id=nl.rijksoverheid.ctr.holder" |-|-|-|-
`iosMinimumVersion`| "2.3.1" |-|-|-|-
`iosRecommendedVersion`| "2.3.1" |-|-|-|-
`iosMinimumVersionMessage`| "Om de app te gebruiken heb je de laatste versie uit de store nodig." |-|-|-|-
`iosAppStoreURL`| "https://apps.apple.com/nl/app/coronacheck/id1548269870" |-|-|-|-
`appDeactivated`| false |-|-|-|-
`configTTL`| 2419200 |-|-|-|-
`configMinimumIntervalSeconds`| 43200 |-|-|-|-
`upgradeRecommendationInterval`| 24 |-|-|-|-
`maxValidityHours`| 24 |-|-|-|-
`informationURL`| "https://coronacheck.nl" |-|-|-|-
`requireUpdateBefore`| 1620781181 |-|-|-|-
`ggdEnabled`| true |-|-|-|-
`euLaunchDate`| "2021-06-30T22:00:00Z" |-|-|-|-
`recoveryGreencardRevisedValidityLaunchDate`| "2021-11-04T22:00:00Z" |-|-|-|-
`temporarilyDisabled`| false |-|-|-|-
`vaccinationEventValidity`| 14600 |-|-|-|-
`vaccinationEventValidityDays`| 730 |-|-|-|-
`recoveryEventValidity`| 8760 |-|-|-|-
`recoveryEventValidityDays`| 365 |-|-|-|-
`recoveryExpirationDays`| 180 |-|-|-|-
`testEventValidity`| 96 |-|-|-|-
`testEventValidityHours`| 96 |-|-|-|-
`domesticCredentialValidity`| 24 |-|-|-|-
`credentialRenewalDays`| 8 |-|-|-|-
`clockDeviationThresholdSeconds`| 30 |-|-|-|-
`domesticQRRefreshSeconds`| 30 |-|-|-|-
`internationalQRRelevancyDays`| 28 |-|-|-|-
`luhnCheckEnabled`| false |-|-|-|-
`euTestResults`| `[{ "code":"260415000", "name": "Negatief (geen corona)"} ]`|-|-|-|-
`hpkCodes`| `[{"code": "2924528", "name": "Pfizer (Comirnaty)", "vp": "1119349007", "mp": "EU/1/20/1528", "ma": "ORG-100030215"}]` |-|-|-|-
`euBrands`| `[{"code": "EU/1/20/1528", "name": "Pfizer (Comirnaty)"}]` |-|-|-|-
`nlTestTypes`| `[{"code": "pcr", "name": "PCR Test"}]`|-|-|-|-
`euVaccinations`| `[{"code": "1119349007", "name": "SARS-CoV-2 mRNA vaccine"}` |-|-|-|-
`euManufacturers`| `[{"code": "ORG-100001699", "name": "AstraZeneca AB"}]` |-|-|-|-
`providerIdentifiers`| `[{ "name": "CTP-TEST-MVWS", "code": "ZZZ"}]`|-|-|-|-
`universalLinkDomains`| `[{"url": "downloadclose.com","name": "Close app"}]`|-|-|-|-

 

## Verifier app

Setting | Example | Description | Deprecated
-|-|-|-
`androidMinimumVersion`| 2522|-|-
`androidRecommendedVersion`| 2522|-|-
`androidMinimumVersionMessage`| "Om de app te gebruiken heb je de laatste versie uit de store nodig."|-|-
`playStoreURL`| "https://play.google.com/store/apps/details?id=nl.rijksoverheid.ctr.verifier"|-|-
`iosMinimumVersion`| "2.4.1"|-|-
`iosRecommendedVersion`| "2.4.1"|-|-
`iosMinimumVersionMessage`| "Om de app te gebruiken heb je de laatste versie uit de store nodig."|-|-
`iosAppStoreURL`| "https://apps.apple.com/nl/app/scanner-voor-coronacheck/id1549842661"|-|-
`appDeactivated`| false|-|-
`configTTL`| 86400|-|-
`configMinimumIntervalSeconds`| 3600|-|-
`upgradeRecommendationInterval`| 24|-|-
`maxValidityHours`| 40|-|-
`clockDeviationThresholdSeconds`| 30|-|-
`informationURL`| "https://coronacheck.nl"|-|-
`defaultEvent`| "cce4158f-582f-49c0-9d4d-611ce3866999"|-|-
`universalLinkDomains`| `[{ "url": "coronacheck.nl", "name":"CoronaCheck app"}]`|-|-
`domesticVerificationRules.qrValidForSeconds` | 60|-|-
`domesticVerificationRules.proofIdentifierDenylist`| `{ "JyoXN+LkbWEjqBvte11m8w==": true }`|-|-
`europeanVerificationRules.testAllowedTypes`| `["LP217198-3"]`|-|-
`europeanVerificationRules.testValidityHours`| 25|-|-
`europeanVerificationRules.vaccinationValidityDelayBasedOnVaccinationDate`| true|-|-
`europeanVerificationRules.vaccinationValidityDelayIntoForceDate`| "2021-07-10"|-|-
`europeanVerificationRules.vaccinationValidityDelayDays`| 14|-|-
`europeanVerificationRules.vaccinationJanssenValidityDelayDays`| 28|-|-
`europeanVerificationRules.vaccinationJanssenValidityDelayIntoForceDate`| "2021-08-14"|-|-
`europeanVerificationRules.vaccineAllowedProducts`| `["EU/1/20/1528"]`|-|-
`europeanVerificationRules.recoveryValidFromDays`| 11|-|-
`europeanVerificationRules.recoveryValidUntilDays`| 180|-|-
`europeanVerificationRules.proofIdentifierDenylist` | `{"q5TKp3sKMWlVjmMUGdhTtw==`| true}`|-|-


# Category based Verification

## Introduction

The Scanner for CoronaCheck app currently validates Domestic QR codes against a fixed set of business rules. To accommodate a more granular way of verifying QR codes depending on changing circumstances, a new `category` field is proposed that can be used to apply a different set of rules based on the given category.

This could be used for cases where, for some events or locations, other access rules apply. These locations would then use a new setting in the CoronaCheck Scanner app to select the categories they support.

The QR codes, upon issuance, are given a specific category based on a set of yet to be determined business rules. 

This document outlines the change to the flow to accommodate such a category.

## Credential update

The basis for this change is a new field `category` in the credential (the basis of the QR codes). Currently we are on version 2 of the credential. When we add the `category` field we will upgrade to version 3.

## Flow

The following diagram depicts the changed flow. Hypothetical categories 'A' and 'B' are used, with an example business rule set that uses the test type to distingish between A and B.

![Verification Flow by Category](images/flow-category-verification.png)

As can be seen in the diagram, the current scanners would assume a certain category for existing QR codes (in this case category A). The following chapter describes the migration process.

## Migration

**Apps**

At time of release of the category field, 2 versions of holder and verifier apps would be in the field. Since a new field in the QR is not backward compatible old verifier apps will refuse the new QR codes. Therfor it's important to do the release process in a number of phases:

1. First deploy a new verifier app that can understand both old and new QR credential versions.
2. After a few days the verifier is forced-updated to this new version to ensure new QRs are accepted everywhere.
3. Next, release a new holder app that can understand new QR credentials.
4. In the signer, 2 endpoints should be provided. 
    1. The /v4 endpoint is the current issuer, which hands out old QRs without category field. These QRs can be read by any version of the holder and verified by any version of the verifier.
    2. The /v5 endpoint is the new issuer, which hands out new QRs with category field. Only new holders will use this endpoint and can understand QRs with this new field.
5. The holder app can be recommended-upgraded to the new version, to aid phase out of older QR codes.    
  
**Paper**

Since paper has a longer validity, current papers are continued to be supported by the new verifier app. The verifier app will assume a category for all paper based on a predetermined preset.

## Impact

### Verifier app ###

The verifier app requires the following changes:

* The mobile core library (written in go) will be upgraded to support v2 and v3 credentials.
* A settings screen must be added to allow agents to select the categories they support.
* The business rules need to be updated to mark the screen red or green based on the scanned QR, now taking into account the new category.

The holder app requires the following changes:

* The UI should be updated to explain the user what category of QR they received and what this means.
* The storage should be updated to be able to store credentials with the new `category` field.
* Existing credentials that are already on the device should, upon upgrade be migrated to the new storage model (even though they will have an empty category).
* If we want to phase out old credentials, the holder should initiate a re-sign of current credentials. This can be done by shortening the refresh window (currently set to 28 days) temporarily, or by introducing a forced refresh. (Note: in the latter case it should be spread to not overload the signers).

The signer requires the following changes:

* Based on to-be-determined business rules, new credentials will be handed out with a new category value.
* Two endpoints should be provided, the current v4 endpoint that hands out old credentials for apps that haven't been upgraded, and a v5 endpoint for upgraded apps.

The print portal requires the following changes:

* The UI should be updated to explain the user what category of QR they received and what this means.

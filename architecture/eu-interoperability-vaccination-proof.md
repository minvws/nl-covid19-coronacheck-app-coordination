# CoronaCheck - European Digital Green Certificate Gateway Interoperabiltiy

Version: 1.0.0
Status: DRAFT

## Overview

### Terminology

DGCG - European Digital Green Certificate Gateway
DGS - Digital Green Certificate
NBS - National Backend Server
DVPS - Digital Vaccination Passport System
CSCA - Country Signing Certificate Authority
NBTLS - National Backend Transport Level Security
NBUS - National Backend Upload Certificate
PKI - Public Key Infrastructure

### Scope

The scope of this document is to specify:

* Integration between CoronaCheck and the new European Digital Green Certificate Gateway (DGCG).
* Data formats and API specifications for integration with the CoronaCheck apps.

It does not cover implementation of digital green certificates in the apps.

## Digital Green Certificate Gateway: Short Introduction

The DGCG is used to share validation and verification information between the national backend servers of the EU members states who who are implementing their own Digital Vaccination Passport Systems.

The verification model is built around cryptographic proof built on Public Key Infrastructure (PKI).

The following certificates:

* Authentication (NBTLS)
* Signing (NBUS)
* Issuer
* Client
* Country Signing Certificate Authority (CSCA) certificate
* DGCS Trust Anchor certificate (DGCSTA)

The NBTLS certificate is used to authenticate our connection with DGCG and the NBUS is used to sign the content we upload to the DGCG. The NBUS and DGCSTA certificates can be used to verify the certificates we receive from DGCS.

The gateway provides an interface which allows member states to upload their certificates, to delete (i.e. revoke) them and to download the certificates from other member states.

Full specifications of the DGCG can be found here: [TODO link when published]

## Solution Design

[ TODO DIAGRAM ]

### DGCG Integration Server

The DGCG integration server is composed out of a set of services. Each service is implemented as a stand-alone cross platform command-line application.

#### DGCG Downloader

This tool is responsible for downloading the trust information from DGCG, verifying it cryptographically, then transforming it into a package ready to be published to our apps.

This tool will be executed on a periodic basis as part of a cron job on Linux or scheduled task on Windows.

#### DGCG Uploader

This tool is responsible packginging, signing then uploading our trust information to the DGCG.

This tool will be executed on an as-needed basis by an administrator.

#### DGCG Revoker

This tool is responsible revoking a certificate with DGCG.

This tool will be executed on an as-needed basis by an administrator.

### API definitions

The following APIs will be provided for the apps.

#### GET /v1/verifier/dgcg_keys

This endpoint will return the following json encoded as a bas64 string, signed, and published in the signed wrapper format specified here [TODO link]

Payload:

```
{
	[{
		"Country": "NL",
		"KeyId": "TBC",
		"DigitA": 123,
		"DigitB": 456
	},{
		"Country": "DE",
		"KeyId": "TBC",
		"DigitA": 123,
		"DigitB": 456
	},
	]
}
````

Country: ISO 2-digit country code of the country.
KeyId: Unique identifier for the key.
DigitA: TBD
DigitB: TBD

This will be distributed on our CDN with the headers [TODO add header information].

## Architechture Design Credits

This design is inspired by the EFGS integration design from CoronaMelder, by Ryan Barrett (ryan@seldonplan.com). 

# Whitepaper: Medical certificate repudiation by private key publication

Authors:
* Mendel Mobach
* Ivo Jansch

## Abstract

The non-repudiation nature of cryptographic digital signatures under some circumstances becomes an undesirable property. During the COVID pandemic, many governments have employed digital means to allow citizens to prove their medical status (e.g. ‘vaccinated’ or ‘tested negative’) to a verifier, for example to gain access to an event. To protect the privacy of citizens it may be important to acknowledge the temporary nature of these certificates. Although many certificates have been issued with a limited validity, the non-repudiation nature of the certificate often outlives the certificate validity; for example an old, expired, certificate can still be verified to be authentic, and thus relaying medical information past the timeframe in which that information was relevant.

For the Dutch ‘Corona Toegangs Bewijs’ (CTB, Corona Access Pass) legislation was passed that stresses the importance of these certificates being temporary. After the CTB was decommissioned, all remaining certificates expired, verification apps were disabled and the issuance of new certificates was halted. By publishing the private key of the CTB, any existing certificate in the field eventually lost its non-repudiation property. In other words, the contents of any certificate has now become deniable. 

In this paper we make the case that the use of non-refutable signatures for medical certificates can be undesirable, or at least non-repudiation must be regarded as a property that is bound to a particular timeframe (such as a pandemic). This impacts the way digital signatures and private/public keys are treated.

## Contents

<!-- TOC start (generated with https://github.com/derlin/bitdowntoc) -->

- [Medical certificate repudiation by private key publication](#medical-certificate-repudiation-by-private-key-publication)
  * [Abstract](#abstract)
  * [Contents](#contents)
  * [1. Background](#1-background)
    + [1.1 What is the CTB?](#11-what-is-the-ctb)
    + [1.2 Why did the CTB use CL signatures?](#12-why-did-the-ctb-use-cl-signatures)
    + [1.3 Key types and sizes](#13-key-types-and-sizes)
    + [1.4 How were the keys used](#14-how-were-the-keys-used)
    + [1.5 What kind of cryptographic security do the keys provide?](#15-what-kind-of-cryptographic-security-do-the-keys-provide)
  * [2. Objectives](#2-objectives)
    + [2.1 Lifting non-repudiation](#21-lifting-non-repudiation)
    + [2.2 Proof of key quality](#22-proof-of-key-quality)
  * [3. Thoughts on the use of Hardware Security Modules](#3-thoughts-on-the-use-of-hardware-security-modules)
  * [4. Publication of the keys](#4-publication-of-the-keys)
  * [5. References](#5-references)

<!-- TOC end -->	

## 1. Background

### 1.1 What is the CTB?

The CTB (Corona Access Pass) was introduced in March 2021 as a way to open up society during periods of lockdowns. The idea was that the risk of COVID transmission could be reduced by opening up certain events or venues only to those people that were tested negative for COVID. Later that year, when vaccinations against COVID became available, the CTB was changed to include vaccination or recovery from COVID as preconditions to enter events or venues. 

The CTB was developed with privacy by design [1]: the QR code that a visitor showed did not contain more information than necessary to be allowed access. This meant that the QR did not contain whether the person was vaccinated, negatively tested or recovered from COVID - only that one of those three must be true without disclosing which one. The validity of a certificate (how long it is valid) might give away that a person was vaccinated since negative test certificates were only valid for 24 hours as opposed to the 180 days that a vaccination was valid. This was remedied by chopping the QR code up into smaller, one-day-size pieces, so that each QR code, regardless of vaccination/test origin, was always only valid for 24 hours [2]. 

To be able to verify if visitors were showing their own personal QR codes and not that of others, the QR code contained a minimum set of identifying information: the initials, the birth month and the birth day (not the year). 

This combination of 4 elements ensured that the identifiers were sufficiently unique that a match against an ID card or passport would give reasonable certainty that the person owned the QR, but not unique enough to be uniquely identifying (there would always be a couple of 100 people with the same set of initials [3]. 

For reasons of inclusivity, the QR codes of the CTB were also available on paper. Since paper certificates needed to be usable over a longer time, they could not make use of the chopping up of QR codes. Therefore, the paper version of the CTB had a privacy trade-off: it could reveal a person's vaccination status. 

### 1.2 Why did the CTB use CL signatures?

To allow the scanner to validate whether a QR code was authentic, it was digitally signed. The CTB used Camenisch-Lysyanskaya [5] signatures, which provided 'multishow unlinkability' to the CTB: the digital signature was randomized in such a way that multiple scans of the same proof would yield different signatures, which could all be verified for authenticity, while not being linkable [5].

### 1.3 Key types and sizes

The CL signature scheme supports multiple key types and key sizes. For the CTB a 1024 bit RSA keys were used. This key size was a tradeoff between security and the ability to scan, because the amount of data you can squeeze in a QR is limited, larger data sizes make the QR more difficult to scan. To mitigate the risk of using 1024 bit instead of 2048 bit key sizes, the keys were rotated every 3 months.

### 1.4 How were the keys used

The process of obtaining a CTB was as follows:
A provider of medical services (vaccinations and/or COVID tests) would generate a 'record' which proved that a person was either tested negatively, had COVID in the past, or was vaccinated. This record contained only the details that were necessary to establish if a person was eligible for a CTB.
This record was digitally signed using a CMS[^1] signature by the provider.
The Ministry of Health, Welfare and Sports ran a 'signer' service which evaluated the record against a set of business rules that established eligibility. 
If eligible, the Ministry would issue a CTB using the current 1024 bit RSA private key to sign the CTB.
A verifier would check the signature against the public key of the key pair, which was published as part of the verifier configuration. The verifier configuration itself was signed with a CMS signature so that a root of trust was established and the verifier knew that the public key was authentic. 

### 1.5 What kind of cryptographic security do the keys provide?

The CL RSA key provided the following cryptographic security:
It proved that the generated CTB was issued by the Ministry of Health, Welfare and Sports. 
It proved that the data in the CTB could not have been altered after issuance.
It provided non-repudiation to the issued CTB.

For the purpose of this document, it is important to realize that this cryptographic security is future proof: Non-repudiation means that even if the keys would be revoked, any CTB can still be verified to be authentic and having been issued in the past. In other words, its content cannot be denied.

An exception to this is key compromise: should the private key be unintentionally leaked to the public, from that point on anyone would be able to generate CTBs, with any data set, representing any moment in time. If the keys would be compromised, all certificates become repudiable. 

## 2. Objectives

In this paper we advocate the deliberate publication of private keys, to serve 2 objectives:

### 2.1 Lifting non-repudiation

In the previous chapter we established that cryptographic keys used in signature schemes for medical certificates provide non-repudiation. Because a medical certificate contains personal details (e.g. a paper certificate reveals a person's vaccination status), non-repudiation is sometimes not a desirable property for the user. With controversy surrounding COVID vaccinations, persons are not always keen on having their vaccination status revealed [6]. As such, persons might want to repudiate their vaccination certificates, so that if someone found their QR code, they could deny the authenticity of the certificate. 

A common way to revoke certificates is to revoke or de-publish the public key. This however does not provide true repudiation: a public list of trustable certificates is merely a social construct. Someone who has in the past downloaded the public keys, can still validate the authenticity of past certificates, knowing that upon issuance, the key was valid and therefore, the certificate remains authentic.

Once a public key is public it stays public forever; even if it is removed from the official trust list, there is nothing to prevent others from holding on to the public key.

To provide the ability to repudiate past certificates, now that the certificates are no longer in use, the private key would have to become compromised, but this time intentionally. Compromising the private key by publishing it, provides anyone with repudiation of their past certificates: now, anyone can generate certificates with arbitrary content and a valid signature. Since the timestamp is part of the signed data, someone obtaining the private key could even backdate the certificates to make it seem like they have always been that way. This contributes to the repudiation. Now, anyone who is confronted with a certificate revealing their vaccination status, is able to deny the authenticity of the certificate by claiming that anyone could have forged the certificate - given that the private key is now published.

Ergo, publishing the private keys provides repudiation to existing medical certificates. 

### 2.2 Proof of key quality

Another objective of publishing the private key is that, in hindsight, anyone can establish that the quality of the keys used for the certificates was sufficient. A digital signature is only as secure as the quality of the key used to generate the signature, so if a low quality key would have been used, any certificate might have been at risk of being forged.

The quality of the key can be determined by the output if a lot of custom data can be used to generate signatures and by analyzing the signatures. This however is a labor (computer/human) intensive process and although it should be deterministic, without the right mathematics, it can’t be used as proof.

Publishing the private key however makes it available for easy mathematical analysis thereby making it very easy to prove the quality of the used keys.

## 3. Thoughts on the use of Hardware Security Modules

It is common to store private keys securely in Hardware Security Modules (HSMs), where they are non-exportable and therefore secure. Despite all the security benefits of this approach, it would make publishing the key, as proposed in this paper, impossible. 

To make certificates repudiable that were signed using keys that are stored in an HSM, an alternative approach could be used: the issuer of the certificates could publish an endpoint and/or web interface that allows users to enter arbitrary data and generate a certificate. Providing users with the ability to sign arbitrary data with the non-exportable keys comes close to allowing them to do that with the published key. This approach however has some drawbacks and limitations: it can only generate certificates that the interface supports, and it only works for as long as the issuer provides access to this interface.

For medical certificates where repudiation at a later date is important, one might consider ensuring that the keys are exportable. This requires alternative security measures to be put in place to ensure the security of the private key.  

## 4. Publication of the Keys

The published keys can be found in the [key_transparency](../key_transparency/) folder of this repository.

## 5. References

[1]		I. Jansch. [CoronaCheck Solution Architecture](https://github.com/minvws/nl-covid19-coronacheck-app-coordination/blob/main/architecture/Solution%20Architecture.md), 2021
[2]		T. Harreveld & I. Jansch. [Privacy Preserving Green Card](https://github.com/minvws/nl-covid19-coronacheck-app-coordination/blob/main/architecture/Privacy%20Preserving%20Green%20Card.md), 2021
[3]		T. Harreveld & D.W. van Gulik. CTB Partial Disclosure Identity, 2021
[4]		J. Camenisch and A. Lysyanskaya. Dynamic accumulators and appli- cation to efficient revocation of anonymous credentials. In M. Yung, editor, Advances in Cryptology — CRYPTO 2002, volume 2442 of Lecture Notes in Computer Science, pages 61–76. Springer Verlag, 2002. 
[5]		I.B. Mobach. [CoronaCheck Security Architecture](https://github.com/minvws/nl-covid19-coronacheck-app-coordination/blob/main/architecture/Security%20Architecture.md), 2021
[6]		K.J. Wu. [People are keeping their vaccines secret](https://www.theatlantic.com/health/archive/2021/03/covid-vaccine-secrecy/618253/), 2021

[^1]: A CMS (Cryptographic Message Syntax) signature is an IETF standard for digitally signing a message in such a way that a recipient can verify that it originated from a particular sender and was not tampered with after applying the signature.		
		


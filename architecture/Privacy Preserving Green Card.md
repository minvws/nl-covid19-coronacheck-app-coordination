# Privacy Preserving Domestic Green Card

*Providing proof of vaccination or a negative test result without disclosing a person's vaccination status.*

Authors: Tomas Harreveld, Ivo Jansch
Version: 0.9

## Introduction

The CoronaCheck app and the CoronaCheck Scanner app are part of the Dutch solution to help open up society safely. People can load a negative test result into the CoronaCheck app, and agents at the entrance of a venue can use the CoronaCheck Scanner app to verify if a person at the door has a valid proof of a recent negative test result.

Recently the team has been tasked with adding support for vaccination certificates. To ensure that noone will be pressured to get vaccinated, and to preserve privacy, we have set a requirement that someone should not have to disclose whether one is vaccinated. A negative test and a recovery certificate should always be available as an alternative to being vaccinated.

This provides us with a challenge: since a negative test has a short validity (currently 40 hours) and a completed vaccination has a long validity (to be determined, but let's for now assume a year), the QR could reveal that someone is vaccinated purely by disclosing that the certificate has a long validity. Although we could decide to hide that fact in the CoronaCheck Scanner app, it would still be in the QR, so a modified or alternative scanner app would still be able to derive vaccination status - therefor we have designed a solution that does not disclose the vaccination status in the QR at all, so that even a rogue scanner would not be able to tell the difference between a vaccinated person, a person with a negative test or a person that has recovered from covid and is considered to be immune.

This document presenets the solution designed by the CoronaCheck team.

NOTE: This is about the Dutch *domestic* solution. For the European 'Digital Green Card' initiative for cross border travel the solution is not applicable (in its current iteration, a European DGC always disclosed vaccination status as well as several other personal details.)

## Current situation


Our team has consistently followed a 'privacy by design' approach, already disclosing as little as possible about the negative result. Currently, a QR presented by the CoronaCheck app contains the following information:

* The `sample date`, which indicated when a person was tested. This value is rounded down to the nearest hour to avoid being able to identify an individual. This date is necessary so the scanner can establish that the test was recent enough.
* The person's initials and birth month/day. This allows an agent to check the result against an ID to ensure people only use their own negative test result. Initials and only a partial birthdate are used to avoid being able to uniquely identify an individual, while still providing enough information to do a visual comparison against an ID. (To ensure 'equal uniqueness' for everyone, some initials and/or the birth day/month may be omited if the combination of the initials is considered to be too unique - e.g. someone with Z Q initials).
* The test type (pcr, antigen) - This was added to be able to distinguish in validity between test types, but is currently not used.
* A digital signature to etablish the authenticity of the test result and to avoid the data values from being tampered with. The system uses a Camenish-Lysyanskaya signature scheme that offers 'unlinkability' properties - in other words, should the signature be scanned multiple times a day, the signature will be different enough to avoid tracking the individual across multiple scans.
* A `credential version` which enables forward/backward compatibility when changes are made to the QR structure.
* A `specimen` flag, to allow test QRs to be generated that can be tested for validity but that will generate a grey 'demo' screen in scanners instead of a green screen.
* An `isPaper` flag

Currently, CoronaCheck Scanner always checks if a QR is valid for 40 hours after the sample date. To be able to ensure that a vaccinated person will be able to enter for a much longer period, the scanner should be able to see the difference between a test result and a vaccination. But this is a conundrum: it needs precisely the information that we are trying to hide.

## The 'strip card' model

To solve the conundrum we break up our domestic green card in little pieces. A 'strippenkaart' is a well known concept in Dutch public transport, where in the past a bus card was made up of 24 or 32 strips, each strip valid for a single trip on a bus, so we've chosen the 'strippenkaart' (strip card in English) as the analogy for this concept.

![Strippenkaart analogy](images/strippenkaart.jpg)

Each strip in the strip card is a credential, which has its own signature and each piece's validity is based on the smallest validity that our various proofs have. The smallest profo is currently valid for 40 hours for a negative test result. Since in the past this validity was subject of debate, and ranged from 24-48 hours, we have chosen to make the strip size 24 hours. Even if the validity of a negative test changes: as long as it's not smaller than 24 hours, we don't need to change the strip card model. 

The next picture depicts a sample strip card for both a negative test and a vaccination:

![Strip card model basics](images/strip_basic.png)

The negative test consists of 2 strips: to cover a 40 hour validity we need 2 24-hour strips. Strips don't have a valid until date, only a valid from date. As such, they don't have to be in sequence; they can overlap. Indeed in this case they must overlap, because 24 + 24 is 48, and we only need 40 hours of validity. So there's an overlap of 8 hours (the second strip starts 8 hours earlier than the first strip ends). This means that multiple strips are valid. The vaccination on the right hand side of the picture has many more strips. When displaying a QR code, the app should select the best strip to show; this is always the strip with the highest startdate, earlier than the time of showing. E.g. at 12 may, 11 am, for the test certificate strip 2 would be shown, for the vaccination it would also be strip 2.

Since the QR includes only the start date, the digital signature and the limited personal information, nothing is revealed about the vaccination status of the user. For CoronaCheck Scanner (or any other scanner for that matter), there is no difference between strips from a vaccination or from a test certificate.

## Strip Renewal

If the validity of a recovery certificate is half a year, then there are 182 strips to generate. 

We will generate only **28 day**s worth of future strips, as depicted in the following picture:

![Strip card model renewals](images/strip_renewal.png)

The reasons we generate only 28 days of strips and not all at once:

* If we have to perform a key roll-over on the private key that signs the certificates, the roll-over period where an old key must still be accepted is at most 28 days.
* If we update the protocol and change the strip format / datastructure, we can roll out new strips to all users within 28 days.
* If a certificate is deemed invalid and should no longer generate strips, a user has at most 28 days of 'still valid' strips in their wallet.

This renewal process means that the CoronaCheck app will have to regularly fetch new strips. To avoid having to fetch strips at the last possible moment before being scanned, this should be opportunistic: If there are less than `minimumSpareStrips` (a config to be added to the app config, initially set to 5) in the wallet and the app happens to be active and online, the app should request new strips. Note that the last strips in the wallet will then be overwritten by the new set. This is generally not a problem. (We may later add a date offset to the signer).

Apps may employ background checks to renew strips when the app is not actively running; note however that iOS and Android only allow background activity if the app has been active in the last couple of days. This could be used however to optimize the reneal. If there are only 2 days more than minimumSpareStrips when the app is running, it may decide to try to fetch the next batch in the background after 2 days. If the user doesn't open their app again, their strips will still be renewed. 

The renewal process should be transparent to the user and is performed by the app without any user interaction. If strip generation fails for a recoverable reason (e.g. server down) and there are still strips left, the renewal can happen at the next attempt.

There will only be user-interaction in the situation where the app needs new strips and the renewal failed and no strips are available. In that case the app must ask the user to go online to re-activate his green card.

## Strip Randomization

It's always been a privacy requirement to hide as much as possible. One of the fields that's been in the domestic green card since the start is the sampleDate. Although it's rounded down to the nearest hour, it still exposes when a person got their test. With the strip card model, we can hide this more, by randomizing the starttime of the strips. As long as the first and last strip have the correct time, intermediary strips do not have such a requirement. As long as each strip has some overlap with the strip before, the actual start time doesn't matter.

The next picture illustrates how strips don't need the same start time as long as they overlap:

![Strip card randomization](images/strip_randomized.png)

For the randomization, we initially choose an overlap of 0-4 hours, e.g. the amount of hours to shorten the next strip's start time is determined by rand() % 5.

### Avoiding unintended disclosure of status

Test and vaccination facilities have opening times that are typically in the 8.00 - 20.00 hour range. This means that the validity of test results, at their current 40 hour validity, always end in the 0.00-12.00 range, whereas vaccinations (which have full-day validities) always end in the 8.00 - 20.00 range. This means there is a gap of 4 hours (20.00 - 0.00) that can never be the end of a validity. Given a 24 hour strip length, it can also never be the start. 

If a strip would start between 20.00 and 0.00, one would be able to derive that this is not a 'start' or 'end' strip but one 'in the middle'. Since negative test results don't have such a 'middle strip', this timing could reveal that the user has either been vaccinated or they had covid in the past. Therefor, start times of 20.00 - 0.00 should be avoided in the randomizer.

## Mass Revocation

The strip renewal gives us a way to ensure strips are never more than 28 days old. Still, there might be a few occasions where it is desirable that strips can be revoked earlier. There is no easy way to do that on a per-case basis, but it can be done in bulk. For example, if at some point it is decided that vaccinations don't last a year but only half a year, and we don't want to allow people to retain their current 28 days worth of strips, then we could bump the credential version that is encoded in a strip, and employ a minimumCredentialVersion config on the holder and scanner apps. 

![Strip card revocation](images/strip_massrevocation.png)

If the app reads its config and `minimumCredentialVersion` is, say 2, whereas the strips left in the wallet are of version 1, then the app could renew those strips immediately. This reduces the time it takes to roll out new strips from 28 days to 3 days (3 days is the maximum allowed time for an app to go without reading a new configuration value).

Note that servers should take into account that if this measure is used, a significant amount of users will start renewing strips, so this couuld generate some additional load. Therefor this feature should only be employed if absolutely necessary.

It is recommended that the scanner also checks the `minimumCredentialVersion`, but only after the holder apps have been able to evaluate the config and renew their strips. In practice this means a delay of 3 days between setting the minimum version in the holder config and the scanner config.

## Paper proofs

For paper proofs the strip card model requires a few changes. Using strips of 24 hours would mean that a user would have to print a proof every day, which is deemed unacceptable from a user point of view. Having a longer validity however does reveal more (e.g. if validity is > 40 hours, it can't be a negative test). For paper proofs, this tradeof is deemed acceptable.

For paper proofs, the strip validity is chosen to be 4 weeks (for recovery/vaccination). 

Currently we have an isPaper flag to distinguish between paper and app strips (app strips have an additional requirement to randomize every 90 seconds, paper does not). To avoid adding another field, which increases the QR size, we replace the isPaper by a stripType field, which has the following values:

* 0 - app strip (validity 40 hours, refresh requirement 3 minutes)
* 1 - paper strip short (validity 40 hours, no refresh requirement)
* 2 - paper strip long (validity 28 days no refresh requirement) 

## Appendix 1: Strip data structure

When this document is implemented, a credential (the technical term for a strip) contains the following data:

* The `start date`, which indicated when the strip starts its validity
* The person's initials and birth month/day. 
* The CL signature 
* A `credential version` 
* A `strip type`, see [Paper proofs chapter](#paper-proofs).
* A `specimen` flag, to allow test QRs to be generated that can be tested for validity but that will generate a grey 'demo' screen in scanners instead of a green screen.

## Appendix 2: Generating credential strips

Terminology:
* Green card validity: The validity of the green card based on the type, e.g. 40h for a test, 365d for a vaccination, 180d for a recovery. (determined by a config)
* Strip granularity: The time between the start of one strip and the next, 24h minus some randomness(determined by a signer config)
* Strip validity: The time that a scanner will deem this strip valid (40 hours, determined by a scanner config)
* Start-strip: The strip at the start of the green card validity
* End-strip: The strip at the end of the green card validity

The following rules should be applied when generating strips:

* The start-strip should *start* on the rounded down sampleDate
* The end-strip should *end* on the rounded down `sampleDate + green card validity`. Since a strip only has a `startDate` and not an `endDate`, the `startDate` of the end-strip is the `endDate - stripValidity` 
* Only generate strips with future validity. This means that the start-strip is sometimes not used.  
* Never generate strips with a startdate higher than `today + 28 days`. This means that the end-strip is only generated when strips are renewed for the final 28 days of the green card validity.
* All other strips should have a startDate that is `previousStrip.startDate + stripGranularity - rand()%5 hours`, causing a random strip overlap of 0-4 hours.

Some of the calculations visualized:

![Strip card calculations](images/strip_calc.png)
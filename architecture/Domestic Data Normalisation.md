# Domestic Data Normalisation

In the domestic QR codes, we have a very minimal set of data. To be able to create European Digital Green Certificates providers provide a dataset that is broader than needed for the domestic proofs. Therefor, the European data is normalized before it is used in a domestic QR. This document describes this normalization.

## Initial normalization

The initials of first name and last name will be normalized according to the following rules:

* Tussenvoegsels / middle names should be ignored. E.g for `van Dam` the initial is D. 
* Accents/diacritics should be removed. E.g Ö becomes O, Ã becomes A, etc.
* If a name starts with a quotation mark, the quote should be skipped. E.g. for a person named `'Aouji` the initial is A
* Special case: if the name starts with a quote followed by a lowercase character and a hyphen, the first uppercase letter after the hyphen should be used. E.g for `'s-Gravezande` the initial is G. 
* The final initial should be uppercase. 
* After normalization the initial matches the regular expression [A-Z]

Rationale: characters outside the range A-Z are easier to link to an actual person because they are more rare (some combinations of initials could point only to a small number of individuals). 


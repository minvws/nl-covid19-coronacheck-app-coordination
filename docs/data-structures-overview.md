# Data Structures

This document provides an overview of the various data structures in use in the CoronaCheck ecosystem. 

# JSON Data Structures

This chapter describes the datastructures that providers of test/vaccination results send to the CoronaCheck app. The protocol for sending the data is [documented here](providing-events-by-digid.md) (for digid based retrieval) and [here](providing-events-by-token.md).

## Protocol version 3.0

Protocol version 3.0 has support for negative tests, positive tests, recovery statements and vaccination events. The current version of the app in the store used protocol version 2.0. Only use 3.0 for preparing for the future version of the app. (Consult with your CoronaCheck liaison when in doubt).

Notes about optional fields:
* Optional does not mean 'never supply it'. Original source data is always better than interpreted values. E.g if you don't know the dose number, don't supply it. If you do know it, please supply it. 
* If you don't have an optional field, either pass null as the value or omit the entire key in json. Do not pass arbitrary values. (E.g. doseNumber '0' is not a valid response). 

### Information Lookup
```javascript
{
    "protocolVersion": "3.0",
    "providerIdentifier": "XXX",
    "informationAvailable": true // true or false if information is available
}
```

### Vaccination Event
```javascript
{
    "protocolVersion": "3.0",
    "providerIdentifier": "XXX",
    "status": "complete", // This refers to the data-completeness, not vaccination status.
    "holder": {
        "firstName": "",
        "infix": "", // optional 
        "lastName": "",
        "birthDate": "1970-01-01" // yyyy-mm-dd (see details below)
    },
    "events": [
        {
            "type": "vaccination",
            "unique": "ee5afb32-3ef5-4fdf-94e3-e61b752dbed9",
            "isSpecimen": true,
            "vaccination": {
                "date": "2021-01-01",
                "hpkCode": "2924528",  // If hpkCode is available, type/manufacturer/brand can be left blank.
                "type": "1119349007",
                "manufacturer": "ORG-100030215", 
                "brand": "EU/1/20/1507", 
                "completedByMedicalStatement": false, // Optional
                "completedByPersonalStatement": false, // Optional
                "country": "NL", // optional iso 3166 2-letter country field, will be set to NL if left out. Can be used if shot was administered abroad
                "doseNumber": 1, // optional, will be based on business rules if left out. If set, should be integer >= 1. 
                "totalDoses": 2, // optional, will be based on business rules / brand info if left out. If set, should be integer >= 1. 
            }
        }
    ]    
}
```

Field details:
* `completedByMedicalStatement`: If known at the provider, mark this vaccination as 'considered complete' (e.g. last in a batch, or *doctor*-based 'this is sufficient for this person' declaration. If unknown, leave this field out instead of using false.
* `completedByPersonalStatement`: This is the self-declared version of the completed statement. If a user has indicated that they only need 1 shot because they recently had covid, use this boolean instead of the medical boolean. In business rules we can then make the distinction whether or not to allow this based on policy.

Authorative Data sources
* hpkCode from the accepted list available on [https://hpkcode.nl/](https://hpkcode.nl/).
* type: [ehealth type list](https://github.com/ehn-digital-green-development/ehn-dgc-schema/blob/main/valuesets/vaccine-prophylaxis.json)
* brand: [ehealth medicinal product list](https://github.com/ehn-digital-green-development/ehn-dgc-schema/blob/main/valuesets/vaccine-medicinal-product.json)
* manufacturer: [ehealth manufacturer list](https://github.com/ehn-digital-green-development/ehn-dgc-schema/blob/main/valuesets/vaccine-mah-manf.json)
* country: [ehealth country list](https://github.com/ehn-dcc-development/ehn-dcc-schema/blob/main/valuesets/country-2-codes.json)


### Negative Test Event

```javascript
{
    "protocolVersion": "3.0",
    "providerIdentifier": "XXX",
    "status": "complete", // This refers to the data-completeness, not test status.
    "holder": {
        "firstName": "",
        "infix": "",
        "lastName": "",
        "birthDate": "1970-01-01" // yyyy-mm-dd (see details below)
    },
    "events": [
        {
            "type": "negativetest",
            "unique": "ee5afb32-3ef5-4fdf-94e3-e61b752dbed7",
            "isSpecimen": true,
            "negativetest": {
                "sampleDate": "2021-01-01T10:00:00Z", 
                "negativeResult": true,
                "facility": "GGD XL Amsterdam",
                "type": "LP6464-4",
                "name": "???",
                "manufacturer": "1232"
            }
        }
    ]    
}
```

Additional field explanations:
* `sampleDate`: The date and time that the test was taken.
    * sampleDate should be rounded **down** to the nearest hour. (To avoid test times in the future). 
    * We deliberately use `sampleDate` and not an expiry after x hours/minutes/seconds. This is because we anticipate that validity might depend on both epidemiological conditions. By including the sample date, the CoronaCheck signer service can control the validity. 
* `type`: The type of test that was used to obtain the result, see below for the value lists to use. 
* `negativeResult`: The presence of a negative result of the covid test. true when a negative result is present. false in all other situations. This is data minimisation: it is not necessary for the app to know whether a person is positive, only that they have had a negative test result. A `false` in the `negativeResult` field could either indicate a positive test, or no test at all, etc.
* `unique`: An opaque string that is unique for this test result for this provider. An id for a test result could be used, or something that's derived/generated randomly. The signing service will use this unique id to ensure that it will only sign each test result once. (It is added to a simple strike list)


Authoritative data sources for values:
* Types: [ehealth test type list](https://github.com/ehn-digital-green-development/ehn-dgc-schema/blob/main/valuesets/test-type.json)
* Manufacturers: [ehealth test manufacturer list](https://github.com/ehn-digital-green-development/ehn-dgc-schema/blob/main/valuesets/test-manf.json)

### Recovery Statement

Statement that a person has recovered from Covid19.

```javascript
{
    "protocolVersion": "3.0",
    "providerIdentifier": "XXX",
    "status": "complete", // This refers to the data-completeness, not test status.
    "holder": {
        "firstName": "",
        "infix": "",
        "lastName": "",
        "birthDate": "1970-01-01" // // yyyy-mm-dd (see details below)
    },
    "events": [
        {
            "type": "recovery",
            "unique": "ee5afb32-3ef5-4fdf-94e3-e61b752dbed7",
            "isSpecimen": true,
            "recovery": {
                "sampleDate": "2021-01-01",
                "validFrom": "2021-01-12",
                "validUntil": "2021-06-30"
            }
        }
    ]    
}
```

### Positive Test Event

For those providers who are unable to provide a recovery event but who are able to provide the result of a positive test, there is an alternative event. Note that it's the exact same structure as a negative event, but with type `positivetest` and a `positiveResult` field.

```javascript
{
    "protocolVersion": "3.0",
    "providerIdentifier": "XXX",
    "status": "complete", // This refers to the data-completeness, not test status.
    "holder": {
        "firstName": "",
        "infix": "",
        "lastName": "",
        "birthDate": "1970-01-01" // yyyy-mm-dd (see details below)
    },
    "events": [
        {
            "type": "positivetest",
            "unique": "ee5afb32-3ef5-4fdf-94e3-e61b752dbed7",
            "isSpecimen": true,
            "positivetest": {
                "sampleDate": "2021-01-01T10:00:00Z", 
                "positiveResult": true,
                "facility": "GGD XL Amsterdam",
                "type": "LP6464-4",
                "name": "???",
                "manufacturer": "1232"
            }
        }
    ]    
}
```

Notes:
* sampleDate should be rounded **down** to the nearest hour. (To avoid test times in the future). 
* We deliberately use `sampleDate` and not an expiry after x hours/minutes/seconds. This is because we anticipate that validity might depend on both epidemiological conditions as well as on where the test result is presented. E.g. a 2-day festival might require a longer validity than a short seminar; By including the sample date, verifiers can control how much data they really see.
* Returning `false` for the `positiveResult` does not necessarily imply 'negative'. This is data minimisation: when requesting a recovery, it is not necessary for the app to know whether a person is negative, only that they have had a positive test result. A `false` in the `positiveResult` field could either indicate a negative test, or no test at all, etc.

Authoritative data sources for values:
* Types: [ehealth test type list](https://github.com/ehn-digital-green-development/ehn-dgc-schema/blob/main/valuesets/test-type.json)
* Manufacturers: [ehealth test manufacturer list](https://github.com/ehn-digital-green-development/ehn-dgc-schema/blob/main/valuesets/test-manf.json)


### Formatting rules

* birthdays:
    * YYYY-MM-DD
    * accepts '00' and 'XX' for month and day, to accommodate unknown birth month/day. Use the value as it appears on a person's id/passport  
* sampleDate for tests: 
    * ISO 8601 date and time
    * Always in utc (Z)
    * No milliseconds 
    * Rounded down to nearest hour 
    * Example: 2021-10-03T10:00:00Z
* dates for vaccinations and recoveries:
    * YYYY-MM-DD
    * No time part 


## Protocol version 2.0

In protocol version 2 we only supported negative test results.

### Negative test result

```javascript
{
    "protocolVersion": "2.0",
    "providerIdentifier": "XXX",
    "status": "complete",
    "result": {
        "sampleDate": "2020-10-10T10:00:00Z", // rounded down to nearest hour
        "testType": "pcr", // must be one of pcr, pcr-lamp, antigen, breath
        "negativeResult": true,
        "unique": "kjwSlZ5F6X2j8c12XmPx4fkhuewdBuEYmelDaRAi",
        "isSpecimen": true, // Optional
        "holder": {
            "firstNameInitial": "J", // Normalized
            "lastNameInitial": "D", // Normalized
            "birthDay": "31", // String, but no leading zero, e.g. "4"
            "birthMonth": "12" // String, but no leading zero, e.g. "4"
        }
    }
}
```

## Protocol version 1.0

This version is now phased out and should not be used by any provider. There are no apps in the field that use this protocol version. 

### Negative test result

```javascript
{
    "protocolVersion": "1.0",
    "providerIdentifier": "XXX",
    "status": "complete",
    "result": {
        "sampleDate": "2020-10-10T10:00:00Z", // rounded to nearest hour
        "testType": "pcr", // must be one of pcr, pcr-lamp
        "negativeResult": true,
        "unique": "kjwSlZ5F6X2j8c12XmPx4fkhuewdBuEYmelDaRAi",
        "checksum": 54,
    }
}
```


# QR Credential Structures

This chapter describes the structure of the QR code that is presented. The QR is ASN.1 encoded.

todo: full ASN notation.

## Credential Version 2

todo: minimum european dataset fields
todo: distinguish between domestic/eu QR code

## Credential Version 1

Attributes:

* isSpecimen
* isPaperProof
* testType
* sampleTime
* firstNameInitial
* lastNameInitial
* birthDay
* birthMonth

Todo: add attribute specs (datatype, etc)


# Data Structures

This document provides an overview of the various data structures in use in the CoronaCheck ecosystem. 

# JSON Data Structures

This chapter describes the datastructures that providers of test/vaccination results send to the CoronaCheck app. The protocol for sending the data is [documented here](https://github.com/minvws/nl-covid19-coronacheck-app-coordination/blob/main/docs/providing-test-results.md#analog-code).

## Protocol version 3.0

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
        "identityHash": "", // The identity-hash belonging to this person.
        "firstName": "",
        "lastName": "",
        "birthDate": "1970-01-01" // ISO 8601
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
                "doseNumber": 1, // optional, will be based on business rules / brand info if left out
                "totalDoses": 2, // optional, will be based on business rules / brand info if left out
            }
        }
    ]    
}
```

Remark on completedByMedicalStatement field: If known at the provider, mark this vaccination as 'considered complete' (e.g. last in a batch, or *doctor*-based 'this is sufficient for this person' declaration. If unknown, leave this field out instead of using false.

Authorative Data sources
* hpkCode from the accepted list available on [https://hpkcode.nl/](https://hpkcode.nl/).
* type: [ehealth type list](https://github.com/ehn-digital-green-development/ehn-dgc-schema/blob/main/valuesets/vaccine-prophylaxis.json)
* brand: [ehealth medicinal product list](https://github.com/ehn-digital-green-development/ehn-dgc-schema/blob/main/valuesets/vaccine-medicinal-product.json)
* manufacturer: [ehealth manufacturer list](https://github.com/ehn-digital-green-development/ehn-dgc-schema/blob/main/valuesets/vaccine-mah-manf.jso)


### Negative Test Event

```javascript
{
    "protocolVersion": "3.0",
    "providerIdentifier": "XXX",
    "status": "complete", // This refers to the data-completeness, not test status.
    "holder": {
        "identityHash": "", // The identity-hash belonging to this person.
        "firstName": "",
        "lastName": "",
        "birthDate": "1970-01-01" // ISO 8601
    },
    "events": [
        {
            "type": "test",
            "unique": "ee5afb32-3ef5-4fdf-94e3-e61b752dbed7",
            "isSpecimen": true,
            "testresult": {
                "sampleDate": "2021-01-01",
                "resultDate": "2021-01-02",
                "negativeResult": true,
                "facility": "GGD XL Amsterdam",
                "type": "???",
                "name": "???",
                "manufacturer": "1232"
            }
        }
    ]    
}
```

Notes:
* We deliberately use `sampleDate` and not an expiry after x hours/minutes/seconds. This is because we anticipate that validity might depend on both epidemiological conditions as well as on where the test result is presented. E.g. a 2-day festival might require a longer validity than a short seminar; By including the sample date, verifiers can control how much data they really see.
* Returning `false` for the `negativeResult` does not necessarily imply 'positive'. This is data minimisation: it is not necessary for the app to know whether a person is positive, only that they have had a negative test result. A `false` in the `negativeResult` field could either indicate a positive test, or no test at all, etc.

### Recovery Statement

```javascript
{
    "protocolVersion": "3.0",
    "providerIdentifier": "XXX",
    "status": "complete", // This refers to the data-completeness, not test status.
    "holder": {
        "identityHash": "", // The identity-hash belonging to this person.
        "firstName": "",
        "lastName": "",
        "birthDate": "1970-01-01" // ISO 8601
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


## Protocol version 2.0

In protocol version 2 we only supported negative test results.

### Negative test result

```javascript
{
    "protocolVersion": "2.0",
    "providerIdentifier": "XXX",
    "status": "complete",
    "result": {
        "sampleDate": "2020-10-10T10:00:00Z", // rounded to nearest hour
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

This version is now phased out. There are no apps in the field that use this protocol version.

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


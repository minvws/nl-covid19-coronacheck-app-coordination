# Data Structures

This document provides an overview of the various data structures in use in the CoronaCheck ecosystem. 

# JSON Data Structures

This chapter describes the datastructures that providers of test/vaccination results send to the CoronaCheck app. The protocol for sending the data is [documented here](https://github.com/minvws/nl-covid19-coronacheck-app-coordination/blob/main/docs/providing-test-results.md#analog-code).

## Protocol version 3.0

// todo: add minimal dataset fields

### Information Lookup
```javascript
{
    "protocolVersion": "3.0",
    "providerIdentifier": "XXX",
    "informationAvailable": true // true or false if information is available
}
````

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
                "doseNumber": 1, 
                "totalDoses": 2, // optional, will be based on brand info if left out
            }
        }
    ]    
}
```

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


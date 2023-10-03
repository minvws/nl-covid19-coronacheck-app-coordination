# Corona Access Pass (CTB) Idemix Keys

This folder contains the public and private keys that were used to create CTB QR codes. An explanation of why these are published can be found in the architecture folder under ['Private Key Publication'](../../architecture/Private%20Key%20Publication.md)

An explanation of the CoronaCheck eco system can be found in the [Solution Architecture](../../architecture/Solution%20Architecture.md) document.

The keys can be created using standard idemix tooling, such as the [IRMA (now Yivi)](https://irma.app/docs/irma-cli/)  command line interface:
```bash
irma issuer keygen --keylength 1024
```

For more information on the use of these keys within the CoronaCheck eco system, please see the [nl-covid19-coronacheck-idemix](https://github.com/minvws/nl-covid19-coronacheck-idemix) repository.

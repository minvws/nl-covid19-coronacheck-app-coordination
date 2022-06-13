# App Store Signing

## Release process

The CoronaCheck apps that are submitted to the app store are created using an automated process based on Github actions, to ensure that the version from GitHub is the version that ends up in the app store. To this end, we have the following measures in place:

* Store builds are generated using a GitHub actions workflow which generates a signed build that can be submitted as-is to the app store.
* After QA processes are complete, the version that gets submitted to the store gets tagged and marked as a release in GitHub, in the private repository
* The code gets synced to the public repository and the tags are set in the public repository as well.
* Our notary process triggers upon release and let's the escrow party know that a validation can be started.
* The escrow party produces a report that indicates that the version that was tagged in Github and the version that is in the store are a match

## Key management

### Apple App Store
The app store distribution certificate that is used to sign the apps is managed by the Rijksoverheid account holder. 

When the key is rotated, Rijksoverheid's account holder will submit the certificate via a secure channel to RDO beheer. 

RDO beheer places the distribtution certificate in Github Secrets. This way developers do not have to have access to the distribution certificate, while the GitHub actions can access it to generate the builds.

### Google Play console
For the play console, a CoronaCheck specific keystore was generated at the start of the project, handed over to Rijksoverheid account holders and injected into the Github Secrets. Similar to the app store, developers do not need access to the keystore.

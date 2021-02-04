#!/bin/sh
set -e

TMPDIR="${TMPDIR:-/tmp}"
OUTDIR="${OUTDIR:-$TMPDIR/example.$$}"
DIR=${PWD}

if [ -e client.crt ]; then
	echo Using existing client.crt demo certificate
else
	echo Generating a client.crt demo certificate
	openssl req -new -x509 -out client.crt -keyout client.crt -subj /CN=Client/O=Example/C=NL -nodes
fi

mkdir -p "${OUTDIR}"
(
	cd "${OUTDIR}"
	cat > content.json <<EOM
{
    "protocolVersion": "1.0",
    "providerIdentifier": "XXX"
    "status": "pending",
    "pollToken": "...", // optional
    "pollDelay": 300, // seconds, optional
}
EOM

	cat content.json | openssl cms -sign -outform DER -out content.sig -signer "${DIR}/client.crt"
	rm -f "${DIR}/client.zip" 
	zip "${DIR}/client.zip" content.json content.sig

	cd "${DIR}"
	rm -rf "${OUTDIR}"
) || exit $?

echo Grenerated a client.zip.
exit 0

	


## **Coronacheck crypto / security informatie**
Datum: 10 april 2020

Auteur: Mendel Mobach

Versie: 1.0

Status: Request for Comment - Needs translation.

Deze versie is niet de finale versie, er is expliciet de mogelijkheid tot commentaar.

*Table 1: Versie historie*

|Versie|Datum|Auteur|Samenvatting|
| :- | :- | :- | :- |
|0.0|2021-02-10|MM||
|0.99|2020-03-31|MM|Commentaar verwerkt|
|1.0|2020-04-10|MM|Commentaar verwerkt|

##
Met dank aan:

Nick ten Cate

Dirk-Willem van Gulik

Tomas Harreveld

Brenno de Winter

Ivo Jansch

Dennis van Zuijlekom

Frank van Vonderen

et. al.

## Introductie
Bij het ontwerpen en opstellen van designeisen van de applicaties is vastgesteld dan privacy en security by design benodig waren. Het samenstelsel van applicaties en data verwerkt gevoelige persoonsgegevens.

Om hierbij te voldoen aan de wettelijke eisen en de implementatie van de BIO-normen is dit document opgesteld.

Hierbij is per maatregel een overweging opgenomen waarom deze maatregel nodig blijkt en waarom dit het gewenste niveau is. Hierbij zijn beheersmogelijkheden, gebruiksvriendelijkheid ook meegewogen naast privacy en security.
## Definities
<u>CL ondertekenen</u>: cryptografische methode genaamd Camenisch-Lysyanskaya om digitale handtekening (of: signature) te zetten.

<u>CMS</u>: PKCS#7 Cryptographic Message Syntax (RFC 5652, 8933), standaard om data/digitale documenten cryptografisch controleerbaar te ondertekenen.

<u>CTP</u>: Corona Test Provider, aanbieder van een coronatest

<u>CoronaCheck Signing Service Ondertekend Testresultaat</u>
Uitgegeven door CoronaCheck Signing Service. Een digitaal document met met daarin de gegevens verwerkt die nodig zijn om een Testbewijs te maken in de Holder-App. Het document bevat een CL signature van de sleutel die beschikbaar is gesteld door MinVWS.

<u>Holder-App (CoronaCheck)</u> De burger die een test heeft ondergaan en deze app wil gebruiken om aan te tonen dat hij of zij in het bezit is van een negatief testresultaat

<u>Verifier-App (CoronaCheck Scanner)</u> De app die gebruikt kan worden om digitaal de authenticiteit van het een ondertekend testbewijs te verifiëren

<u>Testbewijs als QR</u>: Gegenereerd door de Holder-App op basis van CL disclosure. Een digitaal document met bewijs van een negatief testresultaat om te tonen aan de Verifier-App.

<u>Test Provider Ondertekend Testresultaat</u>:
Uitgegeven door de CTP. Digitaal document met bewijs van negatieve testresultaat. Het document bevat een CMS signature van de CTP over deze data.






## Datastromen

Er bestaan de volgende datastromen voor de gebruikers:

1. Ophalen van de ondertekende configuratiebestanden door Holder-App en Verifier-App.
1. Opvragen Testresultaat door de Holder-App bij de CTP.
1. Opvragen en omzetten van een Testresultaat naar een Ondertekend Testresultaat door de Holder-App.
1. Omzetten van een Ondertekend Testresultaat  naar een Testbewijs, offline, in de Holder-App
1. Presenteren Testbewijs door Holder-App aan de Verifier-App.

**Datastroom 1** is het door de app ophalen van de huidige configuratie zoals door MinVWS gepubliceerd. Deze configuratiebestanden zijn voorzien van een controleerbare digitale handtekening waarvan in de App het certificaat van te voren bekend is bij uitlevering.

**Datastroom 2** is vanuit de Holder-App naar de CTP en levert een Testresultaat op dat in de Holder-App nagekeken kan worden.

**Datastroom 3** is het opsturen van het Testresultaat naar CoronaCheck Signing Service (CCSS) om dit om te zetten naar een Ondertekend Testresultaat. Deze wordt door de dienst eerst (nog een keer) gevalideerd.

**Datastroom 4** is het omzetten van een Ondertekend Testresultaat naar een Testbewijs welke gepresenteerd wordt als QR.

**Datastroom 5** is het tonen van het Testbewijs door middel van een QR-code
## Datatransport beveiliging
1) Het datatransport dient versleuteld zijn met HTTPS TLS 1.3 met de juiste ciphers en PFS (of soortgelijk – dus dat een key compromise op dag 10 niet leidt tot confidentialiteit verlies van dag 1-9).
1) Indien uit oogpunt van gebruikersacceptatie oudere OS versies ondersteund dienen te worden zal daar de TLS versie niet lager mogen zijn dan TLS 1.2. (Android < versie 6, iOS < 12.2). 
1) Op de test van Qualys SSL Lab zal een A+ gehaald dienen te worden. 
1) Hiernaast zal aan de eisen van de BIO voldaan moeten worden.
1) SSL pinning: om zeker te stellen dat er alleen met vertrouwde uitgegeven certificaten wordt omgegaan zal er CA (PKI-Overheid EV) en leaf-node pinning worden toegepast. Dit om onder andere Machine In The Middle aanvallen tegen te gaan.

Toegestane TLS ciphers:

*TLS\_AES\_128\_GCM\_SHA256
TLS\_AES\_256\_GCM\_SHA384
ECDHE-RSA-AES128-GCM-SHA256
ECDHE-RSA-AES128-SHA256
ECDHE-RSA-AES256-GCM-SHA384
ECDHE-RSA-AES256-SHA384*

Deze chiphers zijn aangeraden door o.a. mozilla https://ssl-config.mozilla.org/ voor Intermeditia security configuratie. In Modern wordt alleen TlS1.3 geaccepteerd.

**Waar**: Configuratie + ophalen Testresultaat + ophalen CoronaCheck handtekening

**Overwegingen**: Gezien de data door de App zelf wordt opgehaald bij de aanbieder en de data minimale persoonsgegevens bevat is het niet verplicht om end-to-end te versleutelen maar kan volstaan worden met data-transport beveiliging. Geen beveiliging is geen optie hier. Dit geldt ook voor de aanbieders van testresultaten.
Datauitwisseling met de overheid zal op hoog niveau beveiligd dienen te zijn. Door ondertekening, en transportencryptie is dit ruimschoots geborgd.

## Strippen IP adressen
Waar: Ophalen configuratie (CDN) + ophalen handtekening (app en papier)

Welke apps: Holder en Verifier app endpoints.

Het HTTP verkeer dat versleuteld is met TLS gaat door meerdere systemen heen voor het bij de dienst komt. Het begint bij de firewall, daarna komt het op een door de hosting partij beheerde TCP-proxy waar het IP adres verwijderd wordt. Hierna komt het verkeer terecht op een een andere applicatieserver waar TLS-termination plaatsvindt.

Zo kan de hoster niet zien wat voor data er verzonden wordt, en de ondertekeningsservice niet vanaf welk IP adres het verkeer komt. Het is dus onmogelijk om te achterhalen vanaf welk IP-adres een ondertekening van een testresultaat wordt aangevraagd.

**Overwegingen**: Gezien het voor het gebruik van de backend systemen en beveiligingen hiervoor niet nodig is om een relatie te kunnen leggen tussen de gebruiker (IP adres) en de data zal deze niet samen gebundeld moeten kunnen worden in logfiles en foutmeldingen. Door beheer gescheiden uit te voeren is dit ook organisatorisch efficient te borgen.

Het gebruik van IP-adressen is nog steeds nodig om te communiceren over het internet, dus ze moeten wel gebruikt worden.

## Aanleveren Test Provider Ondertekend Testresultaat
Het Testresultaat dient te worden aangeleverd door de CTP voorzien van een PKCS#7 / CMS signature op basis van een PKI-Overheid certificaat met minimaal een SHA256 hash en RSA-PSS padding. SHA256 voldoet ook aan de SOGIS Agreed Cryptographic Mechanisms.

In de app zal de door MinVWS gepubliceerde lijst publieke sleutels bekend zijn waarmee gecontroleerd kan worden of dit Testresultaat door MinVWS geaccepteerd zal worden voor het omzetten naar een Testbewijs.

Dit is een goed beheerde en ondertekende lijst in beheer van MinVWS en beheerd volgens de geldende BIO normen. De sleutel van deze ondertekening zal in de HSM opgeslagen zijn.

Dit Testresultaat dient alleen te worden aangeleverd via een gecontroleerde methode waarbij er met redelijke mate van waarschijnlijkheid kan worden uitgegaan dat de gebruiker ook de bedoelde patiënt is. Dit zoals bedoeld in NEN7510.

Hierbij is bijvoorbeeld acceptabel om DigiD midden te gebruiken of een bijna realtime controle via SMS indien er niet van DigiD gebruik gemaakt kan worden.

**Overwegingen**: Aangezien de burger zelf de data ontvangt en deze op eigen initiatief doorstuurt is het nodig dat er geverifieerd kan worden dat deze data niet is gemanipuleerd. Encryptie is niet nodig omdat de burger juist zelf moet kunnen controleren of de data correct is.


## Inhoud TestResultaat
Het Testresultaat bevat uitsluitend:

- Een unieke code voor deze test. Dit om het resultaat uniek te maken.
- De datum/tijd van de test, naar beneden afgerond op een uur
- Het testtype
- De aanwezigheid van een negatief resultaat.
- De dag van de geboortedatum
- De maand van de geboortedatum
- De eerste letter van de voornaam
- De eerste letter van de achternaam
- Een ondertekening over de bovenstaande data
- Of het een demonstratie code betreft 

**Overwegingen**: Dit is de minimale set om aan de vereisten te voldoen zodat de app-set op grote schaal gebruikt kan worden. Minder gegevens levert op vele vlakken mogelijkheden tot fraude. Meer gegevens levert minder privacy en niet een substantiële fraude-reductie.

## Aanleveren Testbewijs
De Holder-App levert het Testresultaat aan aan de CoronaCheck backend. Deze zet het Testresultaat om naar een Ondertekend Testresultaat door het te voorzien van een niet-herleidbare Camenisch-Lysyanskaya handtekening. De gebruiker kan op basis van deze handtekening aan de Scanner-App elke keer een andere handtekening op het testbewijs leveren waarmee er geen unieke traceerbaarheid van de gebruiker van de Holder-App meer mogelijk is.

### Lengte van de sleutels
Aangezien het mogelijk is om elke week een andere publieke sleutel te gebruiken voor ondertekening kan de lengte van de RSA sleutels in deze CL handtekening korter worden gehouden dan de standaard voorgeschreven 2048 bits.

Gezien de lengte van de sleutel bepalend is voor de hoeveelheid tekens die getoond moeten worden met de QR-code, is het vanuit bruikbaarheids-oogpunt zaak deze zo kort als mogelijk te houden. Daarom is een lengte van 1024 bits hier toegestaan.
### Controle Testresultaat
Bij het aanleveren van een Testresultaat zal de backend van CoronaCheck een controle doen of de handtekening geldig is en gezet is door een CTP in de toegestane lijst van CTP’s.

Indien deze handtekening correct is zal er worden gecontroleerd of dit Testresultaat niet al eerder is uitgegeven. Dit wordt gedaan met een hashtabel, waarin de unieke combinatie van de unieke code van het Testresultaat en de CTP identifier wordt opgenomen samen met een verlooptijd. Periodiek worden testresultaten die verlopen zijn uit de tabel verwijder.

### Herhaaldelijk omzetten van testresultaat###
Het aantal keren dat een QR in de App wordt opgehaald is gemaximeerd op 2 (twee) keer.
Het aantal keren dat een QR voor Print kan worden opgehaald is ongelimiteerd.

De achtergrond achter het beperken van het aantal keren dat een QR-code opgehaald wordt is dat het anders gemakkelijk mogelijk zou zijn om fraude te plegen: de QR-code van de ene persoon kan gemakkelijk ook door een ander opgehaald en gebruikt worden. Zolang er geen goede persoonsidentificatie aan de poort plaatsvind, door het tonen van initialen en geboortedag en maand in de verifier app en deze te vergelijken met die uit een ID bewijs, is dat een ongewenste situatie.


### Inhoud van het Testbewijs
Het Testbewijs bevat maximaal:

- Datum/tijd van testafname
- Initialen van Voornaam en Achternaam
- Dag en maand van de geboortedatum
- Is het bestemd voor papier
- Het test type
- datum en tijd van generatie
- sleutel identifier van de sleutel die is gebruikt.
- Is het een demonstratie code
- Het bovenstaande ondertekend met de CL handtekening 

**Overwegingen**: Voor zover ze nog niet genoemd zijn in de beschrijving: er is niet meer informatie beschikbaar dan er verzonden wordt door de burger, dus meer informatie kan niet. Het gebruik van CTCC cryptografie levert een flinke bijdrage in de privacy omdat er geen relatie gelegd kan worden tussen de verschillende scans bij dezelfde burger en omdat dit 100% offline kan gebeuren waardoor er geen tracering en logging van bestaat.
Door deze ondertekening is het niet meer mogelijk om te bewijzen dat een burger deze ondertekening heeft getoond is het verleden. Hierdoor is er ook in het geval van (illegale) logging geen methode om correlaties tussen scans te leggen.

## Tonen van het Testbewijs
Om elke keer een uniek testbewijs te hebben zonder dat er echte data zoals tijd, delen van de naam en tijdstip uniek horen te zijn wordt er bij het testresultaat een zogeheten nonce toegevoegd. Een meer dan 96 bits groot arbitrair getal per testbewijs. Hiermee wordt geborgd dat een testbewijs uniek te identificeren is voor de ondertekeningsservice.

Bij het tonen van het Testbewijs wordt de nonce uit het bericht verborgen en wordt er een unieke handtekening getoond op basis van de CL-cryptografie.

Ook zal de QR-code van het Testbewijs de datum/tijd van generatie van de QRcode bevatten.

**Overwegingen**: Zodat het niet mogelijk is om screenshots te gebruiken is de QRcode slechts tijdelijk geldig. Hiermee wordt klein en grootschalige fraude tegengegaan. De nonce wordt niet gecommuniceerd zodat ook logging hiervan niet mogelijk is om tracking te doen tussen verschillende scans.
Daarnaast zijn er andere maatregelen genomen om fraude tegen te gaan, animatie, interactie, reactie op de scan en alle niet-technische toegangscontrole maatregelen die bij toegangstesten uitgevoerd kunnen worden.

## Het scannen van het Testbewijs
Bij het scannen van het Testbewijs zal door de CL-ondertekening elke keer dat er een QR-code wordt getoond een testbewijs met andere handtekening worden getoond.

Elke paar minuten zal er een nieuwe QR-code worden getoond zodat tracering tussen de verschillende QR-codes niet mogelijk is.

Daarnaast zal er een visuele indicatie worden getoond waarmee te zien is dat er geen screenshot maar een live beeld getoond wordt.

Bij het scannen van een QR-code die om welke reden dan ook niet wordt herkend als een geldig testbewijs, wordt een rood scherm getoond.

**Overwegingen**: Met een duidelijke kleur van het scherm is het voor de controleur direct duidelijk wat er aan de hand is en zal er daarover minder snel discussie ontstaan. Dat de scanner controleert op de tijd zorgt er wel voor dat de tijd op het device van de scanner en de aanbieder van de qrcode redelijk goed moet staan. Er is hier een marge ingebouwd om kleine fouten in tijd te mitigeren. Hiermee blijft het werkbaar terwijl er toch absolute waarden worden gecommuniceerd.

## HSM gebruik
Ter beveiliging van het proces om borging dat na nodige vernietiging de data niet meer terug te vinden is, ook niet in backups, zal er gebruik gemaakt worden van een Hardware Security Module.

In deze HSM worden de sleutels opgeslagen op een niet exporteerbare manier. Hierdoor is de HSM de enige die een geldige ondertekening op de gevraagde data kan leveren.

Om dit mogelijk te maken wordt de HSM voorzien van een speciale software uitbreiding om  CC-CL cryptografie mogelijk te maken.

De HSM modules zijn in beheer bij JustID PKI, daarmee is het beheer en zijn de operationele en organizatorische procedures zeer goed geregeld. 

**Overwegingen**: Hiermee kunnen de sleutels niet gelekt worden en is misbruik alleen nog mogelijk terwijl er toegang is tot de HSM. Als deze is afgesloten is er geen misbruik meer mogelijk, als de sleutel te kopiëren is zou dit oncontroleerbaar en wel mogelijk zijn.
## Holder-Device
Op het device zal de data veilig en alleen benaderbaar door de app worden opgeslagen. Hierdoor is het voor andere apps niet mogelijk om deze data uit te lezen.

De data zal versleuteld moeten worden opgeslagen zodat er door andere applicaties niet te lezen is wat er in de database staat. Deze sleutel moet voor elk device uniek zijn, op het device aangemaakt moeten worden en alleen aanwezig zijn op het device zelf.

Android: De encryptie zal bij voorkeur gedaan moeten worden met een door StrongBox Keymaster zo breed als mogelijk ondersteunde versleuteling. Indien Strongbox niet beschikbaar is zal er van de Keystore gebruik gemaakt moeten worden.

IOS: Voor IOS dient gebruik te worden gemaakt te worden gemaakt van Keychain

**Overwegingen**: Het zijn gevoelige persoonsgegevens, daarom zal er zorgvuldig mee omgegaan dienen te worden. Dit omvat uiteraard ook veilige opslag.



## Scanner-Device
*Geen speciale eisen voor offline verwerking anders dan een competente camera* 

Voor het verkleinen van de attack surface ten aanzien van het scanner-device, is het verstandig om alle niet-noodzakelijke communicatieprotocollen zoveel mogelijk uit te schakelen.

**Overwegingen:** Het is niet de bedoeling dat er een logboek van controles ontstaat met de controle app. Door basismaatregelen in acht te nemen is de kans groter dat deze gegevens veilig blijven.
## Offline verificatie Testbewijs
**Overwegingen:** Met de voorafgaande beschreven technieken is het niet nodig, zelfs ongewenst, om online te zijn tijdens het tonen van een Testbewijs, dan wel het scannen en verifiëren van een QR-code Testbewijs. Dit om het mogelijk te maken Testbewijzen te controleren in een omgeving waar geen of slechte/langzame internettoegang is. Het voorkomt oponthoud en vertragingen in de doorstroom van gebruikers wanneer er infrastructuur-issues zijn, zoals trage responses, volledige onbeschikbaarheid door een DDoS-aanval, of zelfs dat de actie van het massaal tonen van Testbewijzen zorgt voor een potentiële DDoS op de infrastructuur.

Naast bovenstaande security-overwegingen is offline gebruik privacy-vriendelijker voor gebruikers. Er kunnen geen gegevens uitgewisseld worden met de achterliggende infrastructuur, er kan dus geen data gelogd worden buiten hetgeen in de Scanner-App en/of in de Holder-App eventueel wordt gedaan, en deze software is door het publiek te auditen.



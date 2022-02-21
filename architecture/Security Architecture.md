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
|2.0|2020-10-19|MV|Nieuwe features.

##
Met dank aan:

Nick ten Cate

Dirk-Willem van Gulik

Tomas Harreveld

Brenno de Winter

Ivo Jansch

Dennis van Zuijlekom

Frank van Vonderen

Max Vasterd

et. al.

## Introductie
Het doel van de applicaties omtrent de CoronaCheck app is om de burger weer de vrijheid te kunnen geven die we gewend zijn en daarbij het risico op een COVID-19 besmetting te minimaliseren. Om dit te kunnen bereiken is het verwerken van gevoelige persoonsgegevens niet te voorkomen. Het is daarom van uiterst belang dat alle applicaties op een verantwoorde en veilig manier omgaan bij het verwerken van deze gevoelige persoonsgegevens.

Dit document is bedoeld om de privacy en security implementatie toe te lichten die zijn voortgekomen uit de designeisen. Hierbij wordt toegelicht hoe is voldaan aan de wettelijke eisen en de implementatie van de BIO-normen. 

Dit document bedraagt deze keuzes voor de ontworpen applicaties binnen het ministerie van Volksgezondheid, Welzijn & Sport

Hierbij is per maatregel een overweging opgenomen waarom deze maatregel nodig blijkt en waarom dit het gewenste niveau is. Hierbij zijn beheersmogelijkheden, gebruiksvriendelijkheid ook meegewogen naast privacy en security.

## Definities

<u>CGL</u>: Corona Gegevens Leverancier, Een aangesloten aanbieder die test-, vaccinatie- of herstel-gegevens kan leveren. Voor meer informatie zie: https://github.com/minvws/nl-covid19-coronacheck-provider-docs/blob/main/docs/data-structures-overview.md

<u>Gegevensleverancier Ondertekende Gegevens</u>:
Uitgegeven door de CGL. Digitaal document met vaccinatie of testgegevens. Het document bevat een CMS signature van de CGL over deze data.

<u>CL ondertekenen</u>: Cryptografische methode genaamd Camenisch-Lysyanskaya om digitale handtekening (of: signature) te zetten. Een methode die wordt gebruikt in het Idemix protocol, waarin het doel is om unlinkable signatures te genereren. Waarin niet te achterhalen is door wie de signature is gezet, en daarnaast slechts een beperkte set aan attributen vrij geeft in de handtekening. Hierdoor kan de privacy van gebruikers gehandhaafd worden.

<u>CC-CL</u>: CoronaCheck Camenisch-Lysyanskaya, voorheen CT-CL(CoronaTester Camenisch-Lysyanskaya). Dit is de implementatie van het Idemix protocol (source code: https://github.com/privacybydesign/gabi)

<u>CMS</u>: PKCS#7 Cryptographic Message Syntax (RFC 5652, 8933), standaard om data/digitale documenten cryptografisch controleerbaar te ondertekenen.

<u>CTG</u> Corona Toegangs Gegevens, alle informatie die benodigd is voor een Corona Toegangs Bewijs. Deze gegevens zijn echter nog niet ondertekend door de CoronaCheck Signing Service. Deze gegevens zijn op dit punt wel ondertekend door een CGL

<u>CTB</u> Corona Toegangs Bewijs, CoronaCheck Signing Service Ondertekend toegangsbewijs.
Uitgegeven door CoronaCheck Signing Service. Een digitaal document met daarin de gegevens verwerkt die nodig zijn om een toegangsbewijs te maken in de Holder-App. Het document bevat een CL signature van de sleutel die beschikbaar is gesteld door MinVWS.

<u>CTB als QR</u>: Gegenereerd door de Holder-App op basis van CL disclosure. Een digitaal document om een CTB te tonen aan de Verifier-App. Deze gegevens zijn dan ASN.1 encoded.

<u>DCC</u>: Digital Covid Certificate, vergelijkbaar met de CTB: Echter is deze ondertekend door een Europees goedgekeurd certificaat, en bevat extra informatie met betrekking tot het Bewijs.

<u>CCSS</u>: CoronaCheck Signing Service, gebruikt om CTG mee te ondertekenen. Het resultaat van deze service is een CTB of DCC.

<u>Holder-App (CoronaCheck)</u>: De burger die een test heeft ondergaan en deze app wil gebruiken om aan te tonen dat hij of zij in het bezit is van een CTB

<u>Verifier-App (CoronaCheck Scanner)</u>: De app die gebruikt kan worden om digitaal de authenticiteit van het een ondertekend toegangsbewijs te verifiëren

<u>Identity-hash</u>:
Een (redelijk) anonieme hash die de burger kan gebruiken om uit te vinden of de burger bekend is bij de opvragende instantie.



## Datastromen

Er bestaan de volgende datastromen voor de gebruikers:

1. Inloggen met DigiD voor ophalen BSN
1. Gebruiken van BSN voor ophalen extra gegevens bij RVIG
1. Het maken van een Identity Hash met gegevens RVIG en versturen naar de test en gegevens leveranciers.
1. Ophalen van de ondertekende configuratiebestanden door Holder-App en Verifier-App.
1. Opvragen gegevens bij de CGL's
    * Opvragen Testresultaat-gegevens door de Holder-App bij een aangesloten coronatest leverancier met behulp van een ophaalcode.
    * Opvragen Test- of Vaccinatiegegevens bij een aangesloten dataprovider met behulp van de bovengenoemde identity-hash
1. Opvragen en omzetten van ondertekende gegevens naar een Ondertekend CTB/DCC door de Holder-App.
1. Omzetten van een Ondertekende gegevens  naar een CTB, offline, in de Holder-App
1. Presenteren Toegangsbewijs door Holder-App aan de Verifier-App.

**Datastroom 1** Het BSN van een gebruiker wordt opgehaald door middel van het inloggen bij DigiD. Dit is de Nederlandse identiteitsportaal die gelinkt is aan de BSN van een Nederlandse staatsburger. De BSN die verstuurd wordt door DigiD wordt gedecrypt met de private key behorende bij het PKI overheid certificaat gebruikt om de BSN te encrypten. Dit wordt vervolgens door middel van symmetrische encryptie voor een periode van 15 minuten intern opgeslagen. De sleutel voor deze encryptie dient elke XX maand vervangen te worden.

**Datastroom 2** Zodra de BSN intern is opgeslagen, kan deze gebruikt worden om een identity-hash te maken, om een veilige hash te kunnen berekenen wordt extra informatie opgehaald bij het RVIG.

**Datastroom 3** De verkregen gegevens van het RVIG worden gebruikt een identity-hash te genereren en deze terug te sturen naar de app. Dit wordt vervolgens door de app gebruikt om een Unomi verzoek te versturen naar de CGL's.

**Datastroom 4** is het door de app ophalen van de huidige configuratie zoals door MinVWS gepubliceerd. Deze configuratiebestanden zijn voorzien van een controleerbare digitale handtekening waarvan in de App het certificaat van te voren bekend is bij uitlevering.

**Datastroom 5** vanuit de Holder-App wordt aan de CGL's een gegevens verzoek gedaan. Dit kan op 2 verschillende manieren. Beschreven in 5a en 5b.

**Datastroom 5a** is vanuit de Holder-App naar de CGL met behulp van ophaalcode en levert ondertekende gegevens op dat in de Holder-App nagekeken kan worden.

**Datastroom 5b** is vanuit de Holder-App naar de CGL met behulp van identity-hash en een Unomi verzoek. Indien de identity-hash bekent is bij de CGL levert de CGL de ondertekende gegevens op dat in de Holder-App nagekeken kan worden.

**Datastroom 6** is het opsturen van ondertekende gegevens vanuit de CGL's en naar de CoronaCheck Signing Service (CCSS) sturen om dit om te zetten naar een CTB en DCC. Dit bewijs wordt door de dienst eerst gevalideerd middels het certificaat dat is meegeleverd bij de installatie van de app.

**Datastroom 7** is het omzetten van ondertekende gegevens (CTB of DCC) naar een CTB gepresenteerd als QR. Hierbij wordt gebruik gemaakt van CL disclosure en ASN.1 geëncodeerd.

**Datastroom 8** is het tonen van het toegangsbewijs door middel van een QR-code. Hierbij is het van belang dat de getoonde gegevens niet traceerbaar zijn. 

## Datatransport beveiliging
1) Het datatransport dient versleuteld te zijn met HTTPS TLS 1.3 met de juiste ciphers en PFS (of soortgelijk – dus dat een key compromise op dag 10 niet leidt tot confidentialiteit verlies van dag 1-9).
1) Indien uit oogpunt van gebruikersacceptatie oudere OS versies ondersteund dienen te worden zal daar de TLS versie niet lager mogen zijn dan TLS 1.2. (Android < versie 6, iOS < 12.2). 
1) Op de test van Qualys SSL Lab zal een A+ gehaald dienen te worden. 
1) Er zal aan de eisen van de BIO voldaan moeten worden.
1) SSL OV/EV Controle: Er wordt zeker gesteld dat er voldaan is aan de organisatie verificatieeisen door te controleren op OID 2.23.140.1.2.2 of 2.23.140.1.1
1) SSL Pinning (App config endpoints): Er gebeurt geen TLS/HTTPS pinning op de endpoints. De authenticiteit word gewaarborgd door de CMS signature op de configuratie(s).
1) SSL Pinning (Andere endpoints): Pinning zal gebeuren tegen de in de app config meegeleverde leaf certificaten. 

Toegestane TLS ciphers:

* TLS\_AES\_128\_GCM\_SHA256
* TLS\_AES\_256\_GCM\_SHA384
* ECDHE-RSA-AES128-GCM-SHA256
* ECDHE-RSA-AES128-SHA256
* ECDHE-RSA-AES256-GCM-SHA384
* ECDHE-RSA-AES256-SHA384

Deze chiphers zijn aangeraden door o.a. Mozilla https://ssl-config.mozilla.org/ voor Intermeditia security configuratie. In Modern wordt alleen TLS1.3 geaccepteerd.

**Waar**: Configuratie + ophalen gegevens bij dataprovider + ophalen CoronaCheck handtekening

**Overwegingen**: Geen beveiliging is geen optie hier. Datauitwisseling met de overheid zal op hoog niveau beveiligd dienen te zijn. Gezien de data door de App zelf wordt opgehaald bij de dataprovider en de data minimale persoonsgegevens bevat is het niet verplicht om end-to-end te versleutelen maar kan volstaan worden met data-transport beveiliging. Dit geldt ook voor transport vanuit de verschillende CGL's. Door ondertekening, en transportencryptie zijn de hoge beveiligingseisen ruimschoots geborgd.

Conclusie:

* Configuratie TLS
: Standaard controle van OS wat betreft TLS. Controle tegen CAA records in DNS (beveiligd met DNSSec)

* Configuratie CMS
: Controle dat het certificaat binnen PKI-O (private of public) en volledige controle van CommonName

* Endpoint (provider/signer) TLS
: Controle van het certificaat tegen 1 van de aanwezig certificaten voor dit endpoint in de configuratie

* Endpoint (provider) CMS
: Controle van het certificaat tegen 1 van de aanwezig certificaten voor deze dataleverancier.


## Strippen IP adressen
Waar: Ophalen configuratie (CDN) + ophalen handtekening (app en papier)

Wat: Alle communicatie van Holder en Verifier app endpoints (indien beheert door ministerie van Volksgezondheid, Welzijn en Sport).

Het HTTP verkeer dat versleuteld is met TLS gaat door meerdere systemen heen voor het bij de dienst komt. Het begint bij de firewall, daarna komt het op een door de hosting partij beheerde TCP-proxy waar het IP adres wordt gestript. Voor het strippen geldt voor IPv4 een IPv4/24 subnet mask, voor IPv6 is dit IPv6/48. Hierna komt het verkeer terecht op een een andere applicatieserver waar TLS-termination plaatsvindt.

Zo kan de hoster niet zien wat voor data er verzonden wordt, en de ondertekeningsservice niet exact vanaf welk IP adres het verkeer komt. Het is dus niet langer triviaal om te achterhalen vanaf welk IP-adres een ondertekening voor een CTB wordt aangevraagd.

**Overwegingen**: Gezien het voor het gebruik van de backend systemen en beveiligingen hiervoor niet nodig is om een relatie te kunnen leggen tussen de gebruiker (IP adres) en de data zal deze niet samen gebundeld moeten kunnen worden in logfiles en foutmeldingen. Door beheer gescheiden uit te voeren is dit ook organisatorisch efficient te borgen.

Het gebruik van IP-adressen is nog steeds nodig om te communiceren over het internet, dus ze moeten wel gebruikt worden.

## CMS Signature toegestane certificaten

Voor het ondertekenen van CMS berichten (configuratie, ondertekende gegevens van CGL, etc..) zal gebruik gemaakt worden van een certificaat dat valt binnen de PKI-Overheid chain.

## Aanleveren ondertekende gegevens door Corona Gegevens Leveranciers
De gegevens dienen te worden aangeleverd door de CGL voorzien van een PKCS#7 / CMS signature op basis van een PKI-Overheid certificaat met minimaal een SHA256 hash en RSA-PSS padding. SHA256 voldoet ook aan de SOGIS Agreed Cryptographic Mechanisms.

In de app zal de door MinVWS gepubliceerde lijst publieke sleutels bekend zijn waarmee gecontroleerd kan worden of deze ondertekende gegevens door MinVWS geaccepteerd zal worden voor het omzetten naar een toegangsbewijs.

Dit is een goed beheerde en ondertekende lijst in beheer van MinVWS en beheerd volgens de geldende BIO normen. De sleutel van deze ondertekening zal in de HSM opgeslagen zijn.

### Met behulp van ophaalcode
Het Testresultaat dient alleen te worden aangeleverd via een gecontroleerde methode waarbij er met redelijke mate van waarschijnlijkheid kan worden uitgegaan dat de gebruiker ook de bedoelde patiënt is. Dit zoals bedoeld in NEN7510.

### Met behulp van identity-hash
Een van de manieren om aan ondertekende gegevens te komen is ook door middel van DigiD. Dit authenticatie platform is bedoeld om de identiteit van een Nederlands staatsburgers te controloren. Daarnaast ondersteund dit platform two-factor authenticatie. Dit geeft voldoende zekerheid dat de verstrekte informatie voor de bedoelde patiënt is. Dit BSN wordt vervolgens omgezet in een Identityhash, dit is mogelijk door gegevens op te vragen uit de RVIG en gegevens te combineren met behulp van het HMAC algoritme. Deze extra gegevens zijn nodig om de privacy van de gebruiker te waarborgen bij het opvragen van test en vaccinatie gegevens bij de betreffende leveranciers. De gegevens die worden gebruikt voor de Identity hash zijn de volgende:
    - bsn
    - voornaam
    - achternaam
    - geboortedag

Deze combinatie van gegevens in de hash levert genoeg entropy op om het voor een kwaadwillende niet langer triviaal te maken om te achterhalen om welke persoon het informatie verzoek gaat. Deze hash wordt vervolgens gebruikt om bij de data providers gegevens op te halen van de juiste persoon zonder bekend te maken wie de burger is indien er geen gegevens bekend zijn. Dit gebeurt in 2 stappen, eerst wordt een Unomi verzoek verstuurd waarin wordt gevraagd of de betreffende persoon bekent is in het systeem. En als deze persoon bekent is, wordt een tweede verzoek vestuurd om de test en vaccinatie gegevens op te vragen. Deze twee verzoeken gebeuren beide vanuit de Holder-app. 

Meer informatie over Unomi en de daarbij behorende privacy handhaving staat beschreven in: https://github.com/minvws/nl-covid19-coronacheck-provider-docs/blob/main/docs/providing-events-by-digid.md 

### Met behulp van inscannen bestaande DCC
Daarnaast is het mogelijk om een bestaande DCC in te scannen in de app, met als doel om via de huisarts een digitaal bewijs te kunnen ontvangen. Om dit mogelijk te maken heeft deze persoon ook een koppel code nodig, uitgegeven door diezelfde huisarts die het DCC heeft goedgekeurd. Deze koppelcode is gekoppeld aan de UCI, het documentnummer van de DCC. Op het moment van het inscannen van de DCC wordt om deze koppelcode gevraagd. Zowel het DCC als de koppelcode worden uitgegeven door de huisarts in de vorm een PDF.

**Overwegingen**: Aangezien de burger zelf de data ontvangt en deze op eigen initiatief doorstuurt is het nodig dat er geverifieerd kan worden dat deze data niet is gemanipuleerd. Encryptie is niet nodig omdat de burger juist zelf moet kunnen controleren of de data correct is.


## Inhoud datagegevens
De ondertekende gegevens bevatten uitsluitend de gegevens zoals nodig voor DCC en CTB certificaat zoals gedocumenteerd in https://github.com/minvws/nl-covid19-coronacheck-provider-docs/blob/main/docs/data-structures-overview.md
De vaccinatiegegevens bevatten uitsluiten de gegevens zoals nodig voor DCC en CTB certificaat zoals gedocumenteerd in https://github.com/minvws/nl-covid19-coronacheck-provider-docs/blob/main/docs/data-structures-overview.md

De applicatie stuurt op verzoek van de burger alle gegevens door naar de ondertekeningsservice van VWS zodat er op basis van de gegevens een of meerdere DCC's en/of een CTB uitgegeven kan worden.
De backend service van VWS geeft in de data, ten bate van de QR codes, maximaal de gegevens terug zoals gedefineerd in de europese verordening 2021/931 voor DCC's en zoals hieronder gedefineerd voor CTB onder inhoud van de toegangsbewijzen.

**Overwegingen**: Dit is de minimale set om aan de vereisten te voldoen zodat de app-set op grote schaal gebruikt kan worden. Minder gegevens levert op vele vlakken mogelijkheden tot fraude. Meer gegevens levert minder privacy en niet een substantiële fraude-reductie.

## Aanleveren datagegevens
De Holder-App levert de datagegevens aan de CoronaCheck backend. Deze zet de ondertekende gegevens om naar een CTB door het te voorzien van een niet-herleidbare Camenisch-Lysyanskaya handtekening ten bate van het CTB. De gebruiker kan op basis van dit type handtekening aan de Scanner-App elke keer een andere handtekening op het toegangsbewijs leveren waarmee er geen unieke traceerbaarheid van de gebruiker van de Holder-App meer mogelijk is.

Ook zet de CoronaCheck backend deze gegevens om in een of meerdere DCC's voorzien van de gegevens zoals aangeleverd en/of te deduceren uit de aangeleverde gegevens.

### Lengte van de sleutels
Aangezien het mogelijk is om elke week een andere publieke sleutel te gebruiken voor ondertekening kan de lengte van de RSA sleutels in deze CL handtekening korter worden gehouden dan de standaard voorgeschreven 2048 bits.

Gezien de lengte van de sleutel bepalend is voor de hoeveelheid tekens die getoond moeten worden met de QR-code, is het vanuit bruikbaarheids-oogpunt zaak deze zo kort als mogelijk te houden. Daarom is een lengte van 1024 bits hier toegestaan. De (verkorte) lengte van de sleutel wordt gecompenseerd door elke 3 maanden nieuwe sleutels te activeren. Het activeren van een nieuwe sleutel dient op zijn vroegst 24 uur na publicatie van deze sleutel in de holder app te gebeuren. Dit om te voorkomen dat een nieuwe sleutel niet tijdig herkend wordt. Na het deactiveren van een sleutel, dient deze nog 365 dagen geaccepteerd te worden. Dit omdat het langste CTB 365 dagen geldig is, en deze zo lang geaccepteerd worden.

### Controle ondertekende gegevens
Bij het aanleveren van ondertekende gegevens zal de backend van CoronaCheck een controle doen of de handtekening geldig is en gezet is door een CGL in de toegestane lijst van Corona Gegevens Leveranciers.


### Inhoud van de toegangsbewijzen:

Een toegangsbewijs bevat maximaal:

- Een unieke code voor deze test. Dit om het resultaat uniek te maken.
- De datum/tijd van geldigheid (op papier is dit tot 365 dagen voor vaccinatie, in de app is dit elke dag een nieuwe ondertekening)
- De dag van de geboortedatum
- De maand van de geboortedatum
- De eerste letter van de voornaam
- De eerste letter van de achternaam
- Of het een demonstratie code betreft
- Een ondertekening over de bovenstaande data

**Overwegingen**: Voor zover ze nog niet genoemd zijn in de beschrijving: er is niet meer informatie beschikbaar dan er verzonden wordt door de burger, dus meer informatie kan niet. Het gebruik van CC-CL cryptografie levert een flinke bijdrage in de privacy omdat er geen relatie gelegd kan worden tussen de verschillende scans bij dezelfde burger en omdat dit 100% offline kan gebeuren waardoor er geen tracering en logging van bestaat.
Door deze ondertekening is het niet meer mogelijk om te bewijzen dat een burger deze ondertekening heeft getoond in het verleden. Hierdoor is er ook in het geval van (illegale) logging geen methode om correlaties tussen scans te leggen.

## Tonen van het toegangsbewijs
Om elke keer een uniek toegangsbewijs te hebben zonder dat er echte data zoals tijd, delen van de naam en tijdstip uniek horen te zijn wordt er bij het CTB een zogeheten nonce toegevoegd. Een meer dan 96 bits groot arbitrair getal per toegangsbewijs. Hiermee wordt geborgd dat een toegangsbewijs uniek te identificeren is voor de ondertekeningsservice.

Bij het tonen van het toegangsbewijs wordt de nonce uit het bericht verborgen en wordt er een unieke handtekening getoond op basis van de CL-cryptografie.

Ook zal de QR-code van het toegangsbewijs de datum/tijd van generatie van de QRcode bevatten.

**Overwegingen**: Zodat het niet mogelijk is om screenshots te gebruiken is de QRcode slechts tijdelijk geldig. Hiermee wordt klein en grootschalige fraude tegengegaan. De nonce wordt niet gecommuniceerd zodat ook logging hiervan niet mogelijk is om tracking te doen tussen verschillende scans.
Daarnaast zijn er andere maatregelen genomen om fraude tegen te gaan, animatie, interactie, reactie op de scan en alle niet-technische toegangscontrole maatregelen die bij toegangstesten uitgevoerd kunnen worden. Zie  #**Het scannen van het toegangsbewijs**.

## Het scannen van het toegangsbewijs
Bij het scannen van het toegangsbewijs zal door de CL-ondertekening elke keer dat er een QR-code wordt getoond een toegangsbewijs met andere handtekening worden getoond.

Omdat de QR code regelmatig ververst, is het ook niet mogelijk om een QR Code te traceren. Een malafide scanner app kan dus niet de privacy van de gebruikte QR code in gevaar kunnen brengen. De QR code wordt iedere 30 seconden ververst. Ook is in de scanner app een afwijking van 30 seconden toegestaan. Hierdoor is een maximale afwijking van 60 seconden mogelijk tussen Scanner en Holder applicatie.

Daarnaast zal er een visuele indicatie worden getoond waarmee te zien is dat er geen screenshot maar een live beeld getoond wordt.

Bij het scannen van een QR-code die om welke reden dan ook niet wordt herkend als een geldig toegangsbewijs, wordt een rood scherm getoond.

**Overwegingen**: Met een duidelijke kleur van het scherm is het voor de controleur direct duidelijk wat er aan de hand is en zal er daarover minder snel discussie ontstaan. Dat de scanner controleert op de tijd zorgt er wel voor dat de tijd op het device van de scanner en de aanbieder van de qrcode redelijk goed moet staan. Er is hier een marge ingebouwd om kleine fouten in tijd te mitigeren. Hiermee blijft het werkbaar terwijl er toch absolute waarden worden gecommuniceerd.


## HSM gebruik
Ter beveiliging van het proces om borging dat na nodige vernietiging de data niet meer terug te vinden is, ook niet in backups, zal er gebruik gemaakt worden van een Hardware Security Module voor DCC. Voor de CTB gelden voorlopig door VWS opgestelde beheermaatregelen.

In deze HSM worden de sleutels opgeslagen op een niet exporteerbare manier. Hierdoor is de HSM de enige die een geldige ondertekening op de gevraagde data kan leveren.

De DCC's worden ondertekend met certificaten die voldoen aan de CP en specifiek de CPS zoals opgesteld ten bate van de NL-CSCA-Health.

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

## Offline verificatie toegangsbewijs
**Overwegingen:** Met de voorafgaande beschreven technieken is het niet nodig, zelfs ongewenst, om online te zijn tijdens het tonen van een toegangsbewijs, dan wel het scannen en verifiëren van een QR-code toegangsbewijs. Dit om het mogelijk te maken toegangsbewijzen te controleren in een omgeving waar geen of slechte/langzame internettoegang is. Het voorkomt oponthoud en vertragingen in de doorstroom van gebruikers wanneer er infrastructuur-issues zijn, zoals trage responses, volledige onbeschikbaarheid door een DDoS-aanval, of zelfs dat de actie van het massaal tonen van toegangsbewijzen zorgt voor een potentiële DDoS op de infrastructuur.

Naast bovenstaande security-overwegingen is offline gebruik privacy-vriendelijker voor gebruikers. Er kunnen geen gegevens uitgewisseld worden met de achterliggende infrastructuur, er kan dus geen data gelogd worden buiten hetgeen in de Scanner-App en/of in de Holder-App eventueel wordt gedaan, en deze software is door het publiek te auditen.

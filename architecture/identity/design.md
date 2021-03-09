
# Partial disclosure identity

As stated in the security framework document; it is highly desirable that people cannot
exchange certificates too easily. Of the various methods to prevent this (personalia,
passport photo, etc) the tradeoff made in that document calls for the partial disclosure
of some, but not all, of the data contained in the date of birth, first name and fammily
name. As to allow these to be compared to other data. Such as an identiy card.

However in order to allow the verifier to trust this data - it needs to be in the signed
part of the statement. As the combination of name and date of birth is rather unique, this
will, for most people, break the unlinkability. It makes people uniquely indentifyable
by their data - as they move throuch society.

For this reason *less* data will be used. I.e. just the initial of the first name and, for
example, the month (but not year or day) of birth.

## Tradeoff between security and privacy

For this a tradeoff needs to be made between security and privacy

* Include too much about the person in the Qr code - and they become trackable. Thus 
loosing security.

* Include too little - and it becomes easy to find someone in your immediate social circle
 with whom you can swap a phone.

Note that the vaccination, test or recvery data also contains an issue/expery/time indication. These also
introduce a level of entropy (e.g. if the test cert is 48 hours valid - and the time granualrity is
2 hours -- then an additional 24 permutations are to be added (assuming 24x7 issuing, propalby less)).

These permutations affect the privacy -within- the validity horizon of the certificate. While the other 
data is expescially relevant for identifcatin across certificates. So it is crucial for long lived
certificates to keep these numbers low; less so for very short lived certificates.

## Target

For this effort - two competing targets are to be met.

1. You need to ask several hundred people (333) in order to find someone in your social 
circle with a 'match'. Somewhat taking into account the fact that family names co-incide 
slightly more in your social circle.

1. If a 1000 people are scanned - there should be roughly a 50/50 chance that there is at least one other person with the same 'credentials' as 


## Calculation

On order to find the right strategy - a table with all first letters of the first name and the family name and their incidence is taken.

Note that common prefixes; such as the Dutch 'van, de, etc' are all *removed* prior to taking the first letter.

From here we try several strategies:

* show First initial First name (V) -- so 27 permutations. Some common (J, nearly 13% of the population), some rare (e.g. Q and X).
* show First initial Family name (F) -- again 27 permutations
* show Both (V+F) -- 27x27 permutations. Some common (e.g. J.B. nearly 2 percent of society)
* combine the above with month (1..12) or day(1..31) of birth.
* combine the above month (1..12) *and* day(1..31) of birth.

## Rule

And for each calculate the percentage with that permutation. Any that is within the range set above (0.1% .. 0.3%) is considered acceptable.

Of these we take the one that is:

1. Nearest to the middle of that range
2. If possible does *not* contain a family name (as these are likely to dominate in the social circle).

And if these rules do not yield a solution (for about 3%) of the population - we pick the one nearest to the middle of that range regardless.

## Rule to apply

During issuing - the backend will lookup the V and F in the table; and then include the fields specified in the signed data.

### Example

So for someone called *Albert Akkersloot, Born on the 12 of March 1990* - the rule is *FM*. So included are "V=A" and "M=March" while 'F' and 'D' are left empty.

# Full table

```

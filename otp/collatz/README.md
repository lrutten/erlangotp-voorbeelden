# Collatz

Dit is het Collaz voorbeeld met `rebar3`.

Dit voorbeeld bestaat uit 2 releases:

* [collatz/](collatz/)
* [collatz_verdeler/](collatz_verdeler/)

Deze demo spreidt de berekening van Collatz over meerdere nodes.
Het is de bedoeling dat je eerst de `collatz_verdeler` release start op
één PC en daarna de `collatz` release op alle PC's, ook degene waar de 
`collatz_verdeler` release al draait.

Beide releases hebben de `bootstrap` application aan boord zodat de 
ping tussen de verschillende nodes automatisch loopt. Hierdoor
zijn alle nodes automatisch opgenomen in de cluster.
De `collatz_verdeler` release doet de monitoring van de cluster.
Bij elke nieuwe node of wanneer er een node verdwijnt, krijgt deze
node een event. De `collatz_verdeler` node plaatst alle `collatz` nodes
in een grote ring. Een `collatz` node weet altijd wie zijn opvolger is.

Wanneer een `collatz` node een rekenopdracht krijgt, doet hij één stap van alle
iteraties en stuurt de opdracht voor de rest van de berekening door naar zijn opvolger.
Op deze wijze wordt de hele berekening gedistribueerd uitgevoerd.
Het geheel werkt dynamisch omdat op elk moment een node uit of aan mag gaan.

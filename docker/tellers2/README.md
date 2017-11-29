# `teller2`

In deze versie wordt de `teller` app gestart in 2 containers.
In de release wordt ook de `bootstrap` app gestart.
Deze zorgt voor een automatische clustering.

In `app/teller/config/sys.config` moet voor `bootstrap` de instelling
`multicast` gekozen worden. Anders werkt het niet.

 
~~~~
[
  {teller, []},
  {bootstrap,
    [
       {protocol, multicast}
    ]
  }
].
~~~~

`bootstrap` kiest als defaultwaarde `broadcast` en dit werkt niet.
Het Docker user netwerk heeft een verkeerde instelling voor het broadcastadres.





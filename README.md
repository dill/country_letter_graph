# around the world with start and end letters

Saw this tweet:

[![Tweet by @elle_em Here: Start with the country Ireland. Now name a country that starts with the last letter of 'Ireland.' Keep going like that: the last letter of the country must be the first letter of the next country Without googling how many country names do you need to get 'Ireland' again](toot.png)](https://twitter.com/ellle_em/status/1376485858535206916)

So I thought this was an interesting problem in general: "how can you get from one country name back to itself, where movement is allowed if the first letter of the next country is the same as the last letter of the current country?" So then I thought: how can I get the computer to do this for all countries?

First I took the list of countries [available from Darius Kazemi's `corpora` repository](https://github.com/dariusk/corpora/blob/master/data/geography/countries.json) (these are Anglicised and there are obvious problems with how we define a country, but for the sake of this exercise we'll just use them for now). 

We can load them into R using the `igraph` package (here's a [helpful page on using `igraph`](https://kateto.net/netscix2016.html)) and then use some [embarrassingly simple R code](TKTKTK URL) to find all the first letter to last letter connections.

Since it's a graph, I thought it would be nice to plot it at this stage? Well turns out that plotting graphs nicely is hard and it gets harder with the number of nodes (vertices) in the graph. So we end up with this nonsense:

![A very busy image of a graph with country names overlapping](messy-graph.png)

Looking at this mess made me realise a few things:

1. we only care about start/end letters, so the graph can be simplified to just have vertices for unique start/end combinations (e.g., Australia and Algeria are both coded as "aa").
2. There are some places that only have 1 connection (in or out) so these cul-de-sacs can be pruned from the graph, as we can get back to them (or from them). For example in the above graph we see that Vatican City is such a cul-de-sac.

Applying these two rules we end up with a much simpler representation for the computer (we actually apply the second rule twice, since we end up creating new cul-de-sacs after the first run):

![A graph of nodes with two-letter codes, with far fewer vertices than the previous one](less-messy-graph.png)

In case you were interested, the countries that don't work with this game are:

Bahamas, Barbados, Belarus, Bahrain, Benin, Bhutan, Bangladesh, Belgium, Belize, Bolivia, Bosnia & Herzegovina, Botswana, Bulgaria, Brazil, Brunei, Burundi, Burkina Faso, Fiji, Finland, France, Jamaica, Japan, Jordan, Pakistan, Palau, Peru, Palestinian State, Panama, Papua New Guinea, Paraguay, Poland, Portugal, Vanuatu, Vatican City, Venezuela, Vietnam, Western Sahara, Zambia, Zimbabwe, Haiti, Honduras, Hungary.

Bummer!

This simplification is good because it's easier to see what's going on and because we're about to use an algorithm to find the shortest paths and we'd like to run it as few times as possible. To find the shortest path, we'll use Dijkstra's algorithm, which you can [read more about here](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm) (Dijkstra shunned computers and [had his e-mails printed and hand-wrote replies to them](https://everything2.com/user/rp/writeups/Edsger+W.+Dijkstra)). Fortunately `igraph` has an implementation of the algorithm in its `shortest_paths` function, so we can just apply this for each vertex.

Finally, having done that, we can take the abstracted two letter codes and expand them out to the full set of countries. I've put them in a table below. Note that because there are multiple entries for each two letter code, we end up with multiple possible shortest paths below.

| Start/end |   |   |   |   |   |
|-----------|---|---|---|---|---|
| Afghanistan<br/>Azerbaijan | Namibia<br/>Nicaragua<br/>Nigeria<br/>North Korea<br/>North Macedonia |  |  |  |  |
| Albania<br/>Algeria<br/>Andorra<br/>Angola<br/>Antigua & Barbuda<br/>Argentina<br/>Armenia<br/>Australia<br/>Austria | Albania<br/>Algeria<br/>Andorra<br/>Angola<br/>Antigua & Barbuda<br/>Argentina<br/>Armenia<br/>Australia<br/>Austria |  |  |  |  |
| Cambodia<br/>Canada<br/>China<br/>Colombia<br/>Costa Rica<br/>Croatia<br/>Cuba | Afghanistan<br/>Azerbaijan | New Zealand | Dominican Republic |  |  |
| Cameroon | New Zealand | Dominican Republic |  |  |  |
| Cape Verde<br/>Chile<br/>Cote D'Ivoire | Egypt | Thailand | Dominican Republic |  |  |
| Central African Republic<br/>Czech Republic | Central African Republic<br/>Czech Republic |  |  |  |  |
| Chad | Dominican Republic |  |  |  |  |
| Comoros<br/>Cyprus | Swaziland<br/>Switzerland | Dominican Republic |  |  |  |
| Congo | Oman | New Zealand | Dominican Republic |  |  |
| Democratic Republic of the Congo | Oman | New Zealand |  |  |  |
| Denmark | Kazakhstan<br/>Kyrgyzstan | New Zealand |  |  |  |
| Djibouti | Iceland<br/>Ireland |  |  |  |  |
| Dominica | Afghanistan<br/>Azerbaijan | New Zealand |  |  |  |
| Dominican Republic | Chad |  |  |  |  |
| East Timor<br/>Ecuador<br/>El Salvador | Romania<br/>Russia<br/>Rwanda | Afghanistan<br/>Azerbaijan | Nauru | Ukraine |  |
| Egypt | The Netherlands<br/>The Philippines | Sao Tome & Principe<br/>Sierra Leone<br/>Singapore<br/>Suriname |  |  |  |
| Equatorial Guinea<br/>Eritrea<br/>Estonia<br/>Ethiopia | Afghanistan<br/>Azerbaijan | Nauru | Ukraine |  |  |
| Gabon | Nepal | Luxembourg |  |  |  |
| Gambia<br/>Georgia<br/>Ghana<br/>Grenada<br/>Guatemala<br/>Guinea<br/>Guyana | Afghanistan<br/>Azerbaijan | Nepal | Luxembourg |  |  |
| Germany | Yemen | Nepal | Luxembourg |  |  |
| Greece | Egypt | Taiwan<br/>Tajikistan<br/>Turkmenistan | Nepal | Luxembourg |  |
| Guinea-Bissau | United Arab Emirates | Senegal | Luxembourg |  |  |
| Iceland<br/>Ireland | Djibouti |  |  |  |  |
| India<br/>Indonesia | Afghanistan<br/>Azerbaijan | New Zealand | Djibouti |  |  |
| Iran | New Zealand | Djibouti |  |  |  |
| Iraq | Qatar | Romania<br/>Russia<br/>Rwanda | Afghanistan<br/>Azerbaijan | New Zealand | Djibouti |
| Israel | Laos | Swaziland<br/>Switzerland | Djibouti |  |  |
| Italy | Yemen | New Zealand | Djibouti |  |  |
| Kazakhstan<br/>Kyrgyzstan | New Zealand | Denmark |  |  |  |
| Kenya | Afghanistan<br/>Azerbaijan | New Zealand | Denmark |  |  |
| Kiribati | Iceland<br/>Ireland | Denmark |  |  |  |
| Kosovo | Oman | New Zealand | Denmark |  |  |
| Kuwait | Thailand | Denmark |  |  |  |
| Laos | Senegal |  |  |  |  |
| Latvia<br/>Liberia<br/>Libya<br/>Lithuania | Afghanistan<br/>Azerbaijan | Nepal |  |  |  |
| Lebanon<br/>Liechtenstein | Nepal |  |  |  |  |
| Lesotho | Oman | Nepal |  |  |  |
| Luxembourg | Gabon | Nepal |  |  |  |
| Madagascar<br/>Myanmar | Romania<br/>Russia<br/>Rwanda | Afghanistan<br/>Azerbaijan | Nauru | United Kingdom |  |
| Malawi<br/>Mali | Iran | Nauru | United Kingdom |  |  |
| Malaysia<br/>Malta<br/>Mauritania<br/>Micronesia<br/>Moldova<br/>Mongolia | Afghanistan<br/>Azerbaijan | Nauru | United Kingdom |  |  |
| Maldives<br/>Marshall Islands<br/>Mauritius | South Sudan<br/>Spain<br/>Sudan<br/>Sweden | Nauru | United Kingdom |  |  |
| Mexico<br/>Monaco<br/>Montenegro<br/>Morocco | Oman | Nauru | United Kingdom |  |  |
| Mozambique | Egypt | Tuvalu | United Kingdom |  |  |
| Namibia<br/>Nicaragua<br/>Nigeria<br/>North Korea<br/>North Macedonia | Afghanistan<br/>Azerbaijan |  |  |  |  |
| Nauru | Uzbekistan |  |  |  |  |
| Nepal | Lebanon<br/>Liechtenstein |  |  |  |  |
| New Zealand | Democratic Republic of the Congo | Oman |  |  |  |
| Niger | Romania<br/>Russia<br/>Rwanda | Afghanistan<br/>Azerbaijan |  |  |  |
| Norway | Yemen |  |  |  |  |
| Oman | Nepal | Lesotho |  |  |  |
| Qatar | Romania<br/>Russia<br/>Rwanda | Afghanistan<br/>Azerbaijan | New Zealand | Djibouti | Iraq |
| Romania<br/>Russia<br/>Rwanda | Afghanistan<br/>Azerbaijan | Niger |  |  |  |
| Samoa<br/>Saudi Arabia<br/>Serbia<br/>Slovakia<br/>Slovenia<br/>Somalia<br/>South Africa<br/>South Korea<br/>Sri Lanka<br/>St. Lucia<br/>Syria | Afghanistan<br/>Azerbaijan | Nepal | Laos |  |  |
| San Marino | Oman | Nepal | Laos |  |  |
| Sao Tome & Principe<br/>Sierra Leone<br/>Singapore<br/>Suriname | Egypt | The Netherlands<br/>The Philippines |  |  |  |
| Senegal | Laos |  |  |  |  |
| Seychelles<br/>Solomon Islands<br/>St. Kitts & Nevis<br/>St. Vincent & The Grenadines | Seychelles<br/>Solomon Islands<br/>St. Kitts & Nevis<br/>St. Vincent & The Grenadines |  |  |  |  |
| South Sudan<br/>Spain<br/>Sudan<br/>Sweden | Nauru | United Arab Emirates |  |  |  |
| Swaziland<br/>Switzerland | Dominican Republic | Comoros<br/>Cyprus |  |  |  |
| Taiwan<br/>Tajikistan<br/>Turkmenistan | Nauru | Ukraine | Egypt |  |  |
| Tanzania<br/>Tonga<br/>Tunisia | Afghanistan<br/>Azerbaijan | Nauru | Ukraine | Egypt |  |
| Thailand | Denmark | Kuwait |  |  |  |
| The Netherlands<br/>The Philippines | Sao Tome & Principe<br/>Sierra Leone<br/>Singapore<br/>Suriname | Egypt |  |  |  |
| Togo<br/>Trinidad & Tobago | Oman | Nauru | Ukraine | Egypt |  |
| Turkey | Yemen | Nauru | Ukraine | Egypt |  |
| Tuvalu | Ukraine | Egypt |  |  |  |
| Uganda<br/>United States Of America | Afghanistan<br/>Azerbaijan | Nauru |  |  |  |
| Ukraine | Egypt | Tuvalu |  |  |  |
| United Arab Emirates | South Sudan<br/>Spain<br/>Sudan<br/>Sweden | Nauru |  |  |  |
| United Kingdom | Malawi<br/>Mali | Iran | Nauru |  |  |
| Uruguay | Yemen | Nauru |  |  |  |
| Uzbekistan | Nauru |  |  |  |  |
| Yemen | Norway |  |  |  |  |


# TODO
+ rivedere gestione riferimenti e enabled introducendo i nodi immutabili (serviranno per le tabelle e colonne)
+ backed list
+ brutto maxLength su nodelist

+ supporto per unfreeze
- clone e freeze del nodelist

- riverificare utilizzo del nodeManager (magari non lho appggiamo ma o passiamo su onRegistered)
- rivedere registerAndInstall
- verificare se si può mettere ChildrenLockingSupport in SqlJoinsImpl

- clone intelligente se freezed
- rivedere clone del raw e chi utilizza il costruttore

- Controllo tipo su register Node
- Sqltable e sqlcolumn devono avere le stesse caratteristiche dei loro provider perché se recupero i nodi dalla select devo poter fare quello che facevo prima...oppure devo poter tornare al provider che l'ha generato

- rivedere il clone del custom list
- verificare altri metodi ereditati da custom

- node proveder al posto di nodeconvertable
- utilizzare tonde in tabelle e colonne
- implementare colonne e tabelle cercando di capire il problema dell'immutabilità (sono come le raw ma non posso essere abilitate/disabilitate e avere il ref)
- rivedere fase del clone
- ottimizzazione clone, codice, creazione stringhe e liste
- ottimizzazione formatter con rule più semplici
- migliorare la formattazione della group concat e limit
- gestire la visibilità in modo da proteggere i metodi interni
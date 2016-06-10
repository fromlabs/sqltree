# TODO

- rivedere gli utilizzi di nodefactory e capire se possibile non esporlo. utilizzato dentro ai nodi custom:
    1) per registrare nodi istanziati con nuove classi (registerNode(new GroupConcatClauseImpl()))
    2) per creare nodi interni (createNode(OrderSheetSql.types.ORDER_BY_CLAUSE, null))

- rivedere la creazione del clone
- rivedere operazioni interne su children
    
- implementare colonne e tabelle cercando di capire il problema dell'immutabilità (sono come le raw ma non posso essere abilitate/disabilitate e avere il ref)
- rivedere gestione riferimenti e enabled introducendo i nodi immutabili (serviranno per le tabelle e colonne)
- ottimizzazione formatter con rule più semplici
- ottimizzazione clone, codice, creazione stringhe e liste
- migliorare la formattazione della group concat
- gestire la visibilità in modo da proteggere i metodi interni
# A Smart-Contract to buy pokemon cards
### Tezos Smart contract submission

### Smart contract featues
 * Made using cameLIGO
 * A Smart contract use to buy collectible pokemon cards
 * Manipulates the price of the cards depending on the supply and demand
 * card_rare is a boolean parameter
 * Also those cards who are rare have higher price than normal cards

### Create storage for your contract, Example -
 ```
 Map.literal [ 
  (0n, { 
    current_stock = 12n ; 
    card_address = ("Address of the nft(pokemon card)" : address); 
    card_max_price = 3mutez;
    card_rare = true
  }); 
  (1n, { 
    current_stock = 15n; 
    card_address = ("Address of the nft(pokemon card)" : address); 
    card_max_price = 4mutez;
    card_rare = false
  })
]
 ```



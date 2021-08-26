//defining types
//card_max_price(tez) and card_rare(bool) these will manipulate the price of the card 
type card_supply = { current_stock : nat ; card_address : address ; card_max_price : tez ; card_rare : bool }
type card_storage = (nat, card_supply) map
type return = operation list * card_storage
type card_id = nat

//defining types that are required for card transfer function 
type transfer_destination =
[@layout:comb]
{
  to_ : address;
  card_id : card_id;
  amount : nat;
}
 
defining the transfar type
type transfer =
[@layout:comb]
{
  from_ : address;
  txs : transfer_destination list;
}

//manager address to recieve profits from card sales
let manager_address : address = ("tz1QKFyxygM39QCz6VWBiqhRy2Knhg91k67t" : address)

// the main function
let main (card_kind_index, card_storage : nat * card_storage) : return =
  //checks if the card exist
  let card_kind : card_supply =
    match Map.find_opt (card_kind_index) card_storage with
    | Some k -> k
    | None -> (failwith "The pokemon card you want isn't here :(" : card_supply)
  in

  //checks if the card is rare and gives the price according to that
  let current_purchase_price : tez =
    match(card_kind.card_rare) with
    | true -> card_kind.card_max_price * card_kind.current_stock 
    | false -> card_kind.card_max_price / card_kind.current_stock
  in
  
  //checks if the price is same or not  
  let () = if Tezos.amount <> current_purchase_price then
    failwith "The card has a different price now!"
  in

 //checks if the card is in stock or not
  let () = if card_kind.current_stock = 0n then
    failwith "Better luck next time, the card is out of stock!"
  in

 //update the storage
  let card_storage = Map.update
    card_kind_index
    (Some { card_kind with current_stock = abs (card_kind.current_stock - 1n) })
    card_storage
  in

  let tr : transfer = {
    from_ = Tezos.self_address;
    txs = [ {
      to_ = Tezos.sender;
      card_id = abs (card_kind.current_stock - 1n);
      amount = 1n;
    } ];
  } 
  in

//transaction operation for FA2 transfer
  let entrypoint : transfer list contract = 
    match ( Tezos.get_entrypoint_opt "%transfer" card_kind.card_address : transfer list contract option ) with
    | None -> ( failwith "Invalid external token contract" : transfer list contract )
    | Some e -> e
  in
 
  let fa2_operation : operation =
    Tezos.transaction [tr] 0mutez entrypoint
  in

 //payout functions
  let receiver : unit contract =
    match (Tezos.get_contract_opt manager_address : unit contract option) with
    | Some (contract) -> contract
    | None -> (failwith ("Not a contract") : (unit contract))
  in
 
  let payout_operation : operation = 
    Tezos.transaction unit amount receiver 
  in

//returning the list of operations
 ([fa2_operation ; payout_operation], card_storage)
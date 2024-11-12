use aiken/collection/list
use cardano/assets.{AssetName}
use cardano/transaction.{InlineDatum, Input, NoDatum, Output}
use types.{CFDatum}

pub fn check_mint_amount(outputs: List<Output>, amount: Int) {
  todo
}

pub fn check_mint_tokenname(inputs: List<Input>, asset_name: AssetName) -> Bool {
  let token_name: ByteArray = asset_name
  let counter =
    list.count(
      inputs,
      fn(input) {
        when input.output.datum is {
          InlineDatum(input_datum) -> {
            expect datum: CFDatum = input_datum
            datum.campaign_id == token_name
          }
          NoDatum -> False
          _ -> fail
        }
      },
    )
  counter == 1
}

use aiken/collection/list
use cardano/assets.{AssetName}
use cardano/transaction.{InlineDatum, Input, NoDatum, Output}
use types.{CFDatum}

pub fn check_mint_amount(inputs: List<Input>, output: Output, amount: Int) {
  expect InlineDatum(output_datum) = output.datum
  expect Some(input) =
    list.find(
      inputs,
      fn(input) {
        when input.output.datum is {
          InlineDatum(input_datum) -> input_datum == output_datum
          _ -> False
        }
      },
    )
  assets.lovelace_of(output.value) == assets.lovelace_of(input.output.value) + amount * 1_000_000
}

pub fn check_tokenname(inputs: List<Input>, asset_name: AssetName) -> Bool {
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

pub fn check_burn_amount(inputs: List<Input>, output: Output, amount: Int) {
  expect amount < 0
  expect InlineDatum(output_datum) = output.datum
  expect Some(input) =
    list.find(
      inputs,
      fn(input) {
        when input.output.datum is {
          InlineDatum(input_datum) -> input_datum == output_datum
          _ -> False
        }
      },
    )
  assets.lovelace_of(output.value) == assets.lovelace_of(input.output.value) + amount * 1_000_000
}

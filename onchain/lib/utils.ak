use aiken/collection/dict
//.{Dict}
use aiken/collection/list
// use aiken/crypto.{DataHash}
use aiken/interval.{Finite}
use cardano/address.{Address, Script}
use cardano/assets.{Value}
use cardano/transaction.{
  InlineDatum, Input, Output, OutputReference, Transaction, ValidityRange,
  find_input,
}
use types.{CFDatum}

pub fn get_output_with_unchanged_datum(
  tx: Transaction,
  datum: CFDatum,
  input_utxo: Input,
) -> Output {
  // ) -> Bool {
  expect Script(hash) = input_utxo.output.address.payment_credential
  expect [output_utxo] = tx.outputs |> transaction.find_script_outputs(hash)
  expect InlineDatum(output_datum) = output_utxo.datum
  expect cf_datum: CFDatum = output_datum
  expect cf_datum == datum

  output_utxo
}

pub fn output_value_condition_pledge(
  tx: Transaction,
  input_utxo: Input,
  output_utxo: Output,
) {
  //   datum: CFDatum,
  //   let output = find_output_with_datum(tx.outputs, datum)
  let (_, token_qty): (ByteArray, Int) = find_token_details(tx.mint, input_utxo)
  trace @"TokenQty": token_qty
  (assets.lovelace_of(output_utxo.value) == assets.lovelace_of(
    input_utxo.output.value,
  ) + token_qty * 1_000_000)?
}

pub fn output_value_condition_cancel(
  tx: Transaction,
  input_utxo: Input,
  datum: CFDatum,
) {
  let output = find_output_with_datum(tx.outputs, datum)
  let token: (ByteArray, Int) = find_token_details(tx.mint, input_utxo)
  expect token.2nd < 0
  assets.lovelace_of(output.value) == assets.lovelace_of(
    input_utxo.output.value,
  ) + token.2nd * 1_000_000
  //token amount to lovelace (token.2nd * 1_000_000)
}

pub fn must_be_before_deadline(range: ValidityRange, deadline: Int) -> Bool {
  when range.upper_bound.bound_type is {
    Finite(time) -> (time <= deadline)?
    _ -> fail @"upper_bound NOT Set!"
  }
}

pub fn goal_reached(inputs: List<Input>, goal: Int, oref: OutputReference) {
  expect Some(input) = find_input(inputs, oref)
  assets.lovelace_of(input.output.value) >= goal
}

pub fn datum_updated(outputs: List<Output>, datum: CFDatum) {
  let counter =
    list.count(
      outputs,
      fn(output) {
        when output.datum is {
          InlineDatum(output_datum_data) -> {
            expect output_datum: CFDatum = output_datum_data
            and {
              output_datum.campaign_id == datum.campaign_id,
              output_datum.creator == "",
              output_datum.goal == 0,
              output_datum.deadline == 0,
            }
          }
          _ -> fail
        }
      },
    )
  counter == 1
}

fn find_token_details(mint: Value, input: Input) -> (ByteArray, Int) {
  expect Script(policy_id) = input.output.address.payment_credential
  trace @"PolicyID": policy_id
  expect [Pair(asset_name, amount)] =
    mint
      |> assets.tokens(policy_id)
      |> dict.to_pairs()
  trace @"Token": asset_name, amount
  (asset_name, amount)
}

fn find_output_with_datum(outputs: List<Output>, datum: CFDatum) -> Output {
  expect Some(output) =
    list.find(
      outputs,
      fn(output) {
        when output.datum is {
          InlineDatum(output_datum_data) -> {
            expect output_datum: CFDatum = output_datum_data
            and {
              output_datum.campaign_id == datum.campaign_id,
              output_datum.creator == datum.creator,
            }
          }
          _ -> fail
        }
      },
    )
  output
}
// DEPRECATED
// fn complete_datum(
//   datum: CFDatum,
//   datums: Dict<DataHash, Data>,
// ) -> (DataHash, Data) {
//   expect Some(data_hash) = dict.find(datums, datum)
//   let data_hash: DataHash = data_hash
//   let data: Data = datum
//   (data_hash, data)
// }

// DEPRECATED
// fn must_have_same_datum_and_address(
//   datum: (DataHash, Data),
//   outputs: List<Output>,
//   address: Address,
// ) -> Bool {
//   let counter =
//     list.count(
//       outputs,
//       fn(output) -> Bool {
//         output.address == address && when output.datum is {
//           NoDatum -> False
//           DatumHash(datum_hash) -> datum_hash == datum.1st
//           InlineDatum(datum_data) -> datum_data == datum.2nd
//         }
//       },
//     )
//   counter == 1
// }

// fn utxo_count_1(inputs: List<Input>, datum: CFDatum) {
//   let counter =
//     list.count(
//       inputs,
//       fn(input) -> Bool {
//         when input.output.datum is {
//           InlineDatum(input_datum_data) -> {
//             expect input_datum: CFDatum = input_datum_data
//             input_datum.campaign_id == datum.campaign_id
//           }
//           NoDatum -> True
//           _ -> fail
//         }
//       },
//     )
//   counter == 1
// }

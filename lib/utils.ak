use aiken/collection/list
use cardano/assets
use cardano/transaction.{InlineDatum,
  Input, Output, OutputReference, find_input}
use types.{CFDatum}

/// utxo_count_1 accepts input and checks if only 1 campaign is being updated
pub fn utxo_count_1(inputs: List<Input>, datum: CFDatum) {
  let counter =
    list.count(
      inputs,
      fn(input) -> Bool {
        when input.output.datum is {
          InlineDatum(input_datum_data) -> {
            expect input_datum: CFDatum = input_datum_data
            input_datum.campaign_id == datum.campaign_id
          }
          _ -> fail
        }
      },
    )
  counter == 1
}

// pub fn creator_must_not_change(outputs: List<Output>, datum: CFDatum) {
//   find_output_with_datum(outputs, datum)
// }

pub fn output_value_and_address_condition(
  inputs: List<Input>,
  outputs: List<Output>,
  oref: OutputReference,
  datum: CFDatum,
) {
  expect Some(utxo) = find_input(inputs, oref)
  let output = find_output_with_datum(outputs, datum)
  and {
    output_value_must_be_more(utxo, output),
    deposit_and_output_address_must_be_same(utxo, output),
  }
}

pub fn output_value_must_be_more(input: Input, output: Output) {
  assets.lovelace_of(input.output.value) >= assets.lovelace_of(output.value)
}

pub fn must_be_before_deadline() {
  todo
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

fn deposit_and_output_address_must_be_same(input: Input, output: Output) {
  input.output.address == output.address
}

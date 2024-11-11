use cardano/transaction.{Input, InlineDatum}
use types.{CFDatum}
use aiken/collection/list

pub fn utxo_count_1(inputs: List<Input>, datum: CFDatum) {
  let counter =
    list.count(
      inputs,
      fn(input) -> Bool {
        when input.output.datum is{
            InlineDatum(input_datum_data)->{
                    expect input_datum: CFDatum = input_datum_data
                    input_datum.campaign_id == datum.campaign_id
            }
            _ -> fail
        }
      },
    )
  counter == 1
}

pub fn creator_must_not_change() {
  todo
}

pub fn output_value_must_be_more() {
  todo
}

pub fn must_be_before_deadline() {
  todo
}

use aiken/collection/dict
use aiken/collection/list
use cardano/assets.{PolicyId}
use cardano/transaction.{
  OutputReference, Transaction, find_input, find_script_outputs,
}
use minter
use types.{CFDatum, Redeemer}
use utils

validator crowdfunding {
  spend(
    datum: Option<CFDatum>,
    redeemer: Redeemer,
    oref: OutputReference,
    tx: Transaction,
  ) {
    expect Some(datum) = datum
    when redeemer is {
      0 -> {
        expect Some(input_utxo) = find_input(tx.inputs, oref)
        let output_utxo =
          utils.get_output_with_unchanged_datum(tx, datum, input_utxo)
        trace @"TxOut": output_utxo
        and {
          utils.output_value_condition_pledge(tx.mint, input_utxo, output_utxo)?,
          utils.must_be_before_deadline(tx.validity_range, datum.deadline)?,
        }
      }

      1 -> {
        expect Some(input_utxo) = find_input(tx.inputs, oref)
        let output_utxo =
          utils.get_output_with_unchanged_datum(tx, datum, input_utxo)
        utils.output_value_condition_cancel(tx.mint, input_utxo, output_utxo)?
      }

      2 -> and {
          list.has(tx.extra_signatories, datum.creator),
          or {
            !utils.must_be_before_deadline(tx.validity_range, datum.deadline),
            utils.goal_reached(tx.inputs, datum.goal, oref),
          },
        }

      3 -> and {
          list.has(tx.extra_signatories, datum.creator),
          utils.datum_updated(tx.outputs, datum),
        }

      _ -> fail
    }
  }

  mint(redeemer: Redeemer, policy_id: PolicyId, tx: Transaction) {
    let Transaction { inputs, outputs, mint, .. } = tx
    expect [Pair(asset_name, amount)] =
      mint
        |> assets.tokens(policy_id)
        |> dict.to_pairs()
    trace @"Token": asset_name, amount
    expect [ref_token_utxo] = find_script_outputs(outputs, policy_id)
    trace @"Output": ref_token_utxo
    when redeemer is {
      0 -> and {
          minter.check_mint_amount(inputs, ref_token_utxo, amount)?,
          minter.check_tokenname(inputs, asset_name)?,
        }
      1 -> and {
          minter.check_burn_amount(inputs, ref_token_utxo, amount)?,
          minter.check_tokenname(inputs, asset_name)?,
        }
      _ -> fail @"Invalid redeemer action!"
    }
  }

  else(_) {
    fail @"Unsupported ScriptPurpose"
    // uxto clutter remove (remove the utxo that has no datum no value but are ) cond^ to check incorrect datum or no Datum
  }
}

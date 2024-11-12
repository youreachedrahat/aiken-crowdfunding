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
        and {
          utils.datum_must_not_change(tx, datum, input_utxo),
          utils.output_value_condition_pledge(tx, input_utxo, datum),
          utils.must_be_before_deadline(tx.validity_range, datum.deadline),
        }
      }
      1 -> {
        expect Some(input_utxo) = find_input(tx.inputs, oref)

        and {
          utils.datum_must_not_change(tx, datum, input_utxo),
          utils.output_value_condition_cancel(tx, input_utxo, datum),
        }
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
    expect [ref_token_utxo] = find_script_outputs(outputs, policy_id)
    when redeemer is {
      0 -> and {
          minter.check_mint_amount(inputs, ref_token_utxo, amount),
          minter.check_tokenname(inputs, asset_name),
        }
      1 -> and {
          minter.check_burn_amount(inputs, ref_token_utxo, amount),
          minter.check_tokenname(inputs, asset_name),
        }
      _ -> fail
    }
  }

  else(_) {
    fail
    // uxto clutter remove (remove the utxo that has no datum no value but are ) cond^ to check incorrect datum or no Datum
  }
}

use aiken/collection/list
use cardano/transaction.{OutputReference, Transaction}
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
      0 -> and {
          utils.utxo_count_1(tx.inputs, datum),
          // utils.creator_must_not_change(tx.outputs, datum), // condition check with output_value_must_be_more where I called find_output_with_datum()this check for same id and creator
          utils.output_value_and_address_condition(tx, oref, datum),
          utils.must_be_before_deadline(tx.validity_range, datum.deadline),
        }
      1 -> and {
          // utils.must_have_token(),
          utils.utxo_count_1(tx.inputs, datum),
          utils.datum_must_not_change(tx, datum, oref),
          utils.output_value_correctness(tx, oref, datum),
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
      // 4 -> uxto clutter remove (remove the utxo that has no datum no value but are ) cond^ to check incorrect datum or no Datum
      _ -> fail
    }
  }

  else(_) {
    fail
  }
}

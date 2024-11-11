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
          utils.output_value_and_address_condition(
            tx.inputs,
            tx.outputs,
            oref,
            datum,
          ),
          utils.must_be_before_deadline(),
        }
      // 1 -> pledge cancel
      // 2 -> claim Campaign
      // 3 -> cancel Campaign
      _ -> fail
    }
  }

  else(_) {
    fail
  }
}

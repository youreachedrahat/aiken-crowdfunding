use cardano/transaction.{Transaction}
use types.{CFDatum, Redeemer}
use utils

validator crowdfunding {
  spend(datum: Option<CFDatum>, redeemer: Redeemer, _oref, tx: Transaction) {
    expect Some(datum) = datum
    when redeemer is {
      0 -> and {
          utils.utxo_count_1(tx.inputs, datum),
          utils.creator_must_not_change(),
          utils.output_value_must_be_more(),
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

use aiken/crypto.{VerificationKeyHash}

pub type Redeemer =
  Int

// 0 -> pledge Campaign
// 1 -> pledge cancel
// 2 -> claim Campaign
// 3 -> cancel Campaign

pub type CFDatum {
  campaign_id: ByteArray,
  title: ByteArray,
  creator: VerificationKeyHash,
  deadline: Int,
  goal: Int,
}

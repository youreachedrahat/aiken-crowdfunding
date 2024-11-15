import { Data, Emulator, EmulatorAccount, LucidEvolution, paymentCredentialOf, validatorToAddress } from "@lucid-evolution/lucid";
import { CFDatum } from "../types";
import { spendingValidator } from "../validators";

export async function createCampaign(account: EmulatorAccount, datum: CFDatum, lucid: LucidEvolution, emulator: Emulator) {
  const contractAddress = validatorToAddress(lucid.config().network, spendingValidator);
  lucid.selectWallet.fromSeed(account.seedPhrase);
  

  const tx = await lucid
    .newTx()
    .pay.ToAddressWithData(contractAddress, { kind: "inline", value: Data.to(datum, CFDatum) }, { lovelace: 5_000_000n })
    .complete();

  const signedTx = await tx.sign.withWallet().complete();
  const txHash = await signedTx.submit();

  emulator.awaitTx(txHash);
  console.log("txHash#: ", txHash)
  return txHash;
}

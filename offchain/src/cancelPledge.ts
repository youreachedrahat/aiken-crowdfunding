import { Data, EmulatorAccount, fromText, LucidEvolution, mintingPolicyToId, PolicyId, toUnit, Unit, UTxO, validatorToAddress } from "@lucid-evolution/lucid";
import { CFDatum } from "./types";
import { mintingPolicy, spendingValidator } from "./validators";

export async function cancelPledge(account: EmulatorAccount, datum: CFDatum, lucid: LucidEvolution) {

    const policyId: PolicyId = mintingPolicyToId(mintingPolicy);
    const contractAddress = validatorToAddress(lucid.config().network, spendingValidator);
    lucid.selectWallet.fromSeed(account.seedPhrase);
    const token: Unit = toUnit(policyId, datum.campaign_id);

    const campaignUTxO: UTxO[] = await lucid.utxosAt(contractAddress)
    const redeemer = Data.to(1n);
    const tx = await lucid
        .newTx()
        .mintAssets({ [token]: -50n }, redeemer)
        .attach.MintingPolicy(mintingPolicy)
        .collectFrom(campaignUTxO, redeemer)
        .attach.SpendingValidator(spendingValidator)
        .pay.ToContract(contractAddress, { kind: "inline", value: Data.to(datum, CFDatum) }, { lovelace: 5_000_000n })
        .validTo(Date.now() + 777539_000 - 24 * 3600_000)
        .complete();

    const signed = await tx.sign.withWallet().complete();
    const txHash = await signed.submit();
    console.log("txHash#", txHash)
}
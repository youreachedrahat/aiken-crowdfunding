import {
    Data,
    Emulator,
    EmulatorAccount,
    fromText,
    LucidEvolution,
    mintingPolicyToId,
    paymentCredentialOf,
    PolicyId,
    toUnit,
    Unit,
    UTxO,
    validatorToAddress,
} from "@lucid-evolution/lucid";
import { spendingValidator, mintingPolicy } from "../validators";
import { CFDatum } from "../types";

export async function pledgeCampaign(account: EmulatorAccount, datum: CFDatum, lucid: LucidEvolution, emulator: Emulator) {
    const policyId: PolicyId = mintingPolicyToId(mintingPolicy);
    const contractAddress = validatorToAddress(lucid.config().network, spendingValidator);
    lucid.selectWallet.fromSeed(account.seedPhrase);
    const campaignUTxO: UTxO[] = await lucid.utxosAt(contractAddress)
    
    const lovelaceToSend = campaignUTxO[0].assets.lovelace + 50_000_000n
    const token: Unit = toUnit(policyId, datum.campaign_id);
    const redeemer = Data.to(0n);
    const tx = await lucid
        .newTx()
        .mintAssets({ [token]: 50n }, redeemer)
        .attach.MintingPolicy(mintingPolicy)
        .collectFrom(campaignUTxO, redeemer)
        .attach.SpendingValidator(spendingValidator)
        .pay.ToContract(contractAddress, { kind: "inline", value: Data.to(datum, CFDatum) }, { lovelace: lovelaceToSend })
        .validTo(Date.now() + 777539_000 - 24 * 3600_000)
        .complete();

    const signed = await tx.sign.withWallet().complete();
    const txHash = await signed.submit();
    console.log("txHash#", txHash)
    return txHash
}

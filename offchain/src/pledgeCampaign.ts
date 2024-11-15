import { Data, Emulator, EmulatorAccount, fromText, LucidEvolution, mintingPolicyToId, paymentCredentialOf, PolicyId, toHex, toUnit, Unit, UTxO, validatorToAddress } from "@lucid-evolution/lucid";
import { spendingValidator, mintingPolicy } from "./validators";
import { CFDatum } from "./types";


export async function pledgeCampaign(account: EmulatorAccount, campaignUTxO: UTxO[], lucid: LucidEvolution, emulator: Emulator) {

    const policyId: PolicyId = mintingPolicyToId(mintingPolicy)
    const contractAddress = validatorToAddress(lucid.config().network, spendingValidator);
    const userUtxo = await lucid.utxosAt(account.address);
    lucid.selectWallet.fromSeed(account.seedPhrase)
    const datum: CFDatum = {
        campaign_id: "666f6f",
        title: "666f6f",
        goal: BigInt(100),
        creator: paymentCredentialOf(account.address).hash,
        deadline: BigInt(Date.now() + 777539000)
    }
    // const redeemer = Data.void();
    const token: Unit = toUnit(policyId, fromText("tokenName"))
    const redeemer = Data.to(0n);
    const tx = await lucid
        .newTx()
        .collectFrom([campaignUTxO[0], userUtxo[0]], redeemer)
        .attach.SpendingValidator(spendingValidator)
        .mintAssets({
            [token]: 50n,
        }, redeemer)
        .pay.ToContract(
            contractAddress,
            { kind: "inline", value: Data.to(datum, CFDatum) },
            { lovelace: 55_000_000n }
        )
        .pay.ToAddress(account.address, { [token]: 50n })
        .complete();

    const signed = await tx.sign.withWallet().complete();
    const txHash = await signed.submit();
    // console.log("tx",tx)

}
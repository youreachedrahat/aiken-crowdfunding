import { Address, applyDoubleCborEncoding, MintingPolicy, SpendingValidator } from "@lucid-evolution/lucid"
import cfSpend from "../compiled/spend.json" with {type: "json"}
import cfMint from "../compiled/mint.json" with {type: "json"}

export const spendingValidator: SpendingValidator = {
    script: applyDoubleCborEncoding(cfSpend.cborHex),
    type: "PlutusV3"
}


export const mintingPolicy: MintingPolicy = {
    script: applyDoubleCborEncoding(cfMint.cborHex),
    type: "PlutusV3"
}



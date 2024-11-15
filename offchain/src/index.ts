import { Emulator, generateEmulatorAccount, Lucid, Parameters, paymentCredentialOf } from "@lucid-evolution/lucid";
import { createCampaign } from "./createCampaign";
import { pledgeCampaign } from "./pledgeCampaign";
import { CFDatum } from "./types";
import { cancelPledge } from "./cancelPledge";

export const creator = generateEmulatorAccount({ lovelace: 12_000_000_000n });
export const alice = generateEmulatorAccount({ lovelace: 12_000_000_000n });
export const bob = generateEmulatorAccount({ lovelace: 12_000_000_000n });
export const charlie = generateEmulatorAccount({ lovelace: 12_000_000_000n });

const emulator = new Emulator([creator, alice, bob, charlie]);

const datum: CFDatum = {
  campaign_id: "666f6f",
  title: "666f6f",
  goal: BigInt(100),
  creator: paymentCredentialOf(creator.address).hash,
  deadline: BigInt(Date.now() + 777539000),
};
export async function startContractExe() {
  console.clear();
  console.log("-------------------------Start Emulation-------------------------");

  const lucid = await Lucid(emulator, "Custom");

  emulator.awaitBlock(2);

  console.log("-------------------------Campaign Creation-------------------------");
  const campaignUTxO = await createCampaign(creator, datum, lucid, emulator);
  emulator.awaitBlock(2);

  console.log("-------------------------Campaign Pledge-------------------------");
  await pledgeCampaign(alice, datum, campaignUTxO, lucid, emulator);
  emulator.awaitBlock(2);

  console.log("-------------------------Cancel Pledge-------------------------");
  await cancelPledge(alice, datum, lucid)
  emulator.awaitBlock(2);


  console.log(lucid.utxosAt(alice.address))


}

await startContractExe();

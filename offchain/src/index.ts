import { Emulator, generateEmulatorAccount, Lucid, Parameters, paymentCredentialOf } from "@lucid-evolution/lucid";
import { createCampaign, pledgeCampaign, cancelPledge } from "./campaignFunctions";
// import {  } from "./campaignFunctions/pledgeCampaign";
// import {  } from "./campaignFunctions/cancelPledge";
import { CFDatum } from "./types";

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

  console.log("\n-------------------------Campaign Creation-------------------------");
  emulator.awaitTx(await createCampaign(creator, datum, lucid, emulator))

  console.log("\n-------------------------Campaign Pledge-------------------------");
  emulator.awaitTx(await pledgeCampaign(alice, datum, lucid, emulator))
  emulator.awaitTx(await pledgeCampaign(bob, datum, lucid, emulator))
  emulator.awaitTx(await pledgeCampaign(charlie, datum, lucid, emulator))

  console.log("\n-------------------------Cancel Pledge-------------------------");
  emulator.awaitTx(await cancelPledge(alice, datum, lucid))

}

await startContractExe();

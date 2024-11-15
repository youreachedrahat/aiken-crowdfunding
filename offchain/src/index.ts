import { Emulator, generateEmulatorAccount, Lucid, Parameters, paymentCredentialOf } from "@lucid-evolution/lucid";
import { createCampaign } from "./createCampaign";
import { pledgeCampaign } from "./pledgeCampaign";

export const creator = generateEmulatorAccount({ lovelace: 12_000_000_000n });
export const alice = generateEmulatorAccount({ lovelace: 12_000_000_000n });
export const bob = generateEmulatorAccount({ lovelace: 12_000_000_000n });
export const charlie = generateEmulatorAccount({ lovelace: 12_000_000_000n });

const emulator = new Emulator([creator, alice, bob, charlie]);

export async function startContractExe() {
  console.clear();
  console.log("-------------------------Start Emulation-------------------------");
  console.log("creator", creator.address);

  const lucid = await Lucid(emulator, "Custom");

  emulator.awaitBlock(2); //wait for 2 block

  const campaignUTxO = await createCampaign(creator, lucid, emulator);
  console.log("-------------------------Campaign Created-------------------------");

  await pledgeCampaign(alice, campaignUTxO, lucid, emulator);
}

await startContractExe();

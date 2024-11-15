import { Data } from "@lucid-evolution/lucid";

const DatumSchema = Data.Object({
  campaign_id: Data.Bytes(),
  title: Data.Bytes(),
  creator: Data.Bytes(),
  deadline: Data.Integer(),
  goal: Data.Integer(),
});
export type CFDatum = Data.Static<typeof DatumSchema>;
export const CFDatum = DatumSchema as unknown as CFDatum;

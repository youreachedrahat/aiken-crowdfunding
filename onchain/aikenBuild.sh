aiken build -t verbose
aiken blueprint convert -v crowdfunding.crowdfunding.spend > ../offchain/compiled/spend.json
aiken blueprint convert -v crowdfunding.crowdfunding.mint > ../offchain/compiled/mint.json
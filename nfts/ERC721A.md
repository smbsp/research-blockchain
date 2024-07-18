# How does ERC721A save gas?

ERC721A provides significant gas savings for minting multiple NFTs in a single transaction. It does that by:

1. Removing duplicate storage from OZ's ERC721Enumerable using Bitmaps
2. Updating the owners balance once per batch mint request, instead of per minted NFT. OZ default implementation does not include a batch mint API.
3. Updating the owners data once per batch mint request, instead of per minted NFT.

# Where does it add cost?

# Why shouldn’t ERC721Enumerable’s implementation be used on-chain?

1. It consumes more gas due to more data structures used
2. Slow writes
3. Transfers are costly

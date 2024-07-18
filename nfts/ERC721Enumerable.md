# Revisit the solidity events tutorial. How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable? Explain how you would accomplish this if you were creating an NFT marketplace

Moralis and Alchemy have APIs to find all NFTs that belong to an address. They listen to all block transactions, looking for transfer events for ERC 721/1155 and index it in a centralised Database.

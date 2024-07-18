// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ERC721Enumerable, ERC721, IERC165} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract MyNFT is Ownable2Step, ERC721Enumerable, IERC2981 {
    using EnumerableSet for EnumerableSet.AddressSet;

    address public royaltyRecipient;
    uint256 public royaltyBps;

    bytes32[] public merkleRoots;
    mapping(uint256 => mapping(bytes32 => bool)) public claimed;

    constructor(string memory _name, string memory _symbol, address _royaltyRecipient, uint256 _royaltyBps)
        ERC721(_name, _symbol)
    {
        royaltyRecipient = _royaltyRecipient;
        royaltyBps = _royaltyBps;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, IERC165)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        virtual
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = royaltyRecipient;
        royaltyAmount = (salePrice * royaltyBps) / 10000;
    }

    function setMerkleRoots(bytes32[] memory _merkleRoots) external onlyOwner {
        merkleRoots = _merkleRoots;
    }

    function mintWithDiscount(uint256 tokenId, bytes32[] memory proof, uint256 index, uint256 discount) external {
        require(!_exists(tokenId), "Token already minted");
        require(verifyMerkleProof(proof, index, discount), "Invalid proof");

        _safeMint(msg.sender, tokenId);
    }

    function verifyMerkleProof(bytes32[] memory proof, uint256 index, uint256 discount) internal returns (bool) {
        require(merkleRoots.length > 0, "Merkle roots not set");

        bytes32 node = keccak256(abi.encodePacked(index, discount));
        bytes32 calculatedRoot = node;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (index % 2 == 0) {
                calculatedRoot = keccak256(abi.encodePacked(calculatedRoot, proofElement));
            } else {
                calculatedRoot = keccak256(abi.encodePacked(proofElement, calculatedRoot));
            }

            index /= 2;
        }

        return calculatedRoot == merkleRoots[index];
    }
}

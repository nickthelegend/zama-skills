// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint8, externalEuint8 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract ConfidentialNFT is ERC721, ZamaEthereumConfig, Ownable {
    mapping(uint256 => euint8) private _rarityScores;

    constructor() ERC721("ConfidentialNFT", "CNFT") Ownable(msg.sender) {}

    function mint(address to, uint256 tokenId, externalEuint8 encryptedRarity, bytes calldata proof) public onlyOwner {
        _safeMint(to, tokenId);
        euint8 rarity = FHE.fromExternal(encryptedRarity, proof);
        _rarityScores[tokenId] = rarity;
        
        FHE.allow(rarity, to);
        FHE.allowThis(rarity);
    }

    function getRarity(uint256 tokenId) public view returns (euint8) {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        return _rarityScores[tokenId];
    }
}

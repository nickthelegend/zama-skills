// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, externalEuint64, euint64, eaddress, ebool } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IConfidentialToken {
    function confidentialTransferFrom(address from, address to, euint64 amount) external;
    function confidentialTransfer(address to, euint64 amount) external;
    function confidentialBalanceOf(address account) external view returns (euint64);
}

contract BlindAuction is ZamaEthereumConfig {
    address public beneficiary;
    IConfidentialToken public token;
    IERC721 public nft;
    uint256 public tokenId;

    uint256 public endTime;
    bool public ended;

    euint64 private highestBid;
    eaddress private winningAddress;
    address public winnerAddress;

    mapping(address => euint64) private bids;

    constructor(
        address _token,
        address _nft,
        uint256 _tokenId,
        uint256 _duration
    ) {
        beneficiary = msg.sender;
        token = IConfidentialToken(_token);
        nft = IERC721(_nft);
        tokenId = _tokenId;
        endTime = block.timestamp + _duration;
    }

    function bid(externalEuint64 encryptedAmount, bytes calldata proof) public {
        require(block.timestamp < endTime, "Auction ended");
        
        euint64 amount = FHE.fromExternal(encryptedAmount, proof);
        token.confidentialTransferFrom(msg.sender, address(this), amount);
        
        euint64 currentTotal = FHE.add(bids[msg.sender], amount);
        bids[msg.sender] = currentTotal;

        if (!FHE.isInitialized(highestBid)) {
            highestBid = currentTotal;
            winningAddress = FHE.asEaddress(msg.sender);
        } else {
            ebool isNewWinner = FHE.gt(currentTotal, highestBid);
            highestBid = FHE.select(isNewWinner, currentTotal, highestBid);
            winningAddress = FHE.select(isNewWinner, FHE.asEaddress(msg.sender), winningAddress);
        }
        
        FHE.allowThis(highestBid);
        FHE.allowThis(winningAddress);
    }

    function resolveAuction() public {
        require(block.timestamp >= endTime, "Auction not ended");
        require(!ended, "Already resolved");
        
        bytes32[] memory cts = new bytes32[](1);
        cts[0] = FHE.toBytes32(winningAddress);
        FHE.requestDecryption(cts, this.resolveCallback.selector);
        ended = true;
    }

    function resolveCallback(uint256 requestId, bytes memory cleartexts, bytes memory proof) public {
        FHE.checkSignatures(requestId, cleartexts, proof);
        winnerAddress = abi.decode(cleartexts, (address));
    }

    function claim() public {
        require(ended, "Not resolved");
        require(msg.sender == winnerAddress, "Not winner");
        token.confidentialTransfer(beneficiary, highestBid);
        nft.transferFrom(address(this), winnerAddress, tokenId);
    }
}

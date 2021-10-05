// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MarketToken is ERC721 {
    constructor() ERC721("MarketToken", "TEI") {}

    function mintToMsgSender(address approved) public {
        for (uint256 i = 0; i < 10; i++) {
            _safeMint(msg.sender, i);
        }
        setApprovalForAll(approved, true);
    }

    function getAllNftsOf(address owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 nrOfNfts = balanceOf(owner);
        uint256[] memory nfts = new uint256[](nrOfNfts);
        uint256 index = 0;
        uint256 nftIndex = 0;
        while (nrOfNfts != 0) {
            if (ownerOf(index) == owner) {
                nrOfNfts -= 1;
                nfts[nftIndex] = index;
                nftIndex += 1;
            }
            index += 1;
        }
        return nfts;
    }
}

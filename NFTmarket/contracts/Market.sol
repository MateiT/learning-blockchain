// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./IMarket.sol";
import "./MarketToken.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Market is IMarket {
    Listing[] public listings;
    uint256 creationPrice; //%
    uint256 purchaseFee; //%
    address payable owner;

    constructor() {
        owner = payable(msg.sender);
        creationPrice = 1;
        purchaseFee = 2;
    }

    /// @dev The price of creating a new listing.
    function listingCreationPrice() external view override returns (uint256) {
        return creationPrice;
    }

    /// @dev Percentage of the purchasing price that is retained by the Market operator.
    function listingPurchaseFee() external view override returns (uint256) {
        return purchaseFee;
    }

    /// @dev Get all active listings.
    function activeListings()
        external
        view
        override
        returns (uint256[] memory)
    {
        uint256 lenght = listings.length;
        uint256[] memory actives = new uint256[](lenght);
        uint256 activesLenght = 0;

        for (uint256 i = 0; i < lenght; i++) {
            if (listings[i].status == Status.Active) {
                actives[activesLenght] = i;
                activesLenght++;
            }
        }
        return actives;
    }

    /// @dev Get the details of a listing.
    function getListing(uint256 _listing)
        external
        view
        override
        returns (Listing memory)
    {
        require(_listing < listings.length);
        return listings[_listing];
    }

    /// @dev Create a new listing.
    function createListing(
        address _contract,
        uint256 _token,
        uint256 _price
    ) external payable override returns (uint256 listing) {
        uint256 expectedPay = (_price * creationPrice) / 100;

        require(msg.value >= expectedPay, "Prea putina plata!");

        _payOwner(expectedPay);

        ERC721(_contract).approve(address(this), _token);

        listings.push(
            Listing(_contract, _token, msg.sender, _price, Status.Active)
        ); //msg.sender?

        emit ListingCreated(_contract, _token, msg.sender, _price);
        return listings.length - 1;
    }

    /// @dev Cancel an active listing.
    function cancelListing(uint256 _listing) external override {
        require(_listing < listings.length);
        listings[_listing].status = Status.Canceled;
        ERC721(listings[_listing].contract_).approve(
            address(0),
            listings[_listing].token
        );
        emit ListingCanceled(_listing);
    }

    function getOwnerOfNft(uint256 id) external view returns (address) {
        return ERC721(listings[id].contract_).ownerOf(id);
    }

    function getNftsOfOwner(address tokenOwner, address tokenAddress)
        external
        view
        returns (uint256[] memory)
    {
        return MarketToken(tokenAddress).getAllNftsOf(tokenOwner);
    }

    /// @dev Purchase an active listing.
    function purchase(uint256 _listing) external payable override {
        require(_listing < listings.length);

        address buyer = msg.sender;
        address seller = listings[_listing].seller;
        uint256 payedPrice = msg.value;
        uint256 tokenId = listings[_listing].token;
        uint256 tokenPrice = listings[_listing].price;

        require(tokenPrice <= payedPrice);

        uint256 forOwner = (payedPrice * purchaseFee) / 100;

        _payOwner(forOwner);
        _payTo(seller, tokenPrice - forOwner);

        ERC721(listings[_listing].contract_).approve(buyer, tokenId);
        ERC721(listings[_listing].contract_).transferFrom(
            seller,
            buyer,
            tokenId
        );

        listings[_listing].status = Status.Sold;
        emit ListingSold(_listing);
    }

    function _payTo(address _to, uint256 _sum) private {
        require(_sum < address(this).balance);
        address payable to = payable(_to);
        to.transfer(_sum);
    }

    function _payOwner(uint256 _sum) private {
        require(_sum < address(this).balance);
        owner.transfer(_sum);
    }
}

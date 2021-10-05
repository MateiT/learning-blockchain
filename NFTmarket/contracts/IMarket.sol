// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/// @dev A marketplace for selling/purchasing NFTs to/from other users.
interface IMarket {
    /// @dev The status of a listing
    enum Status {
        Canceled,
        Active,
        Sold
    }

    /// @dev The data stored for each listing on this Market
    struct Listing {
        address contract_;
        uint256 token;
        address seller;
        uint256 price;
        Status status;
    }

    /// @dev Event that is emitted when a listing is created.
    event ListingCreated(
        address indexed _contract,
        uint256 indexed _token,
        address indexed _seller,
        uint256 _price
    );

    /// @dev Event that is emitted when a listing is canceled.
    event ListingCanceled(uint256 indexed _listing);

    /// @dev Event that is emitted when a listing is sold.
    event ListingSold(uint256 indexed _listing);

    /// @dev The price of creating a new listing.
    function listingCreationPrice() external view returns (uint256);

    /// @dev Percentage of the purchasing price that is retained by the Market operator.
    function listingPurchaseFee() external view returns (uint256);

    /// @dev Get all active listings.
    function activeListings() external view returns (uint256[] memory);

    /// @dev Get the details of a listing.
    function getListing(uint256 _listing)
        external
        view
        returns (Listing memory);

    /// @dev Create a new listing.
    function createListing(
        address _contract,
        uint256 _token,
        uint256 _price
    ) external payable returns (uint256 listing);

    /// @dev Cancel an active listing.
    function cancelListing(uint256 _listing) external;

    /// @dev Purchase an active listing.
    function purchase(uint256 _listing) external payable;
}

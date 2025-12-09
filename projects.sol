pragma solidity ^0.8.0;

contract NFTArtMarketplace {
    struct NFT {
        uint256 id;
        address creator;
        address owner;
        string metadata;
        uint256 price;
        bool forSale;
    }

    uint256 public nftCount;
    mapping(uint256 => NFT) public nfts;
    mapping(address => uint256[]) public userNFTs;

    event NFTCreated(uint256 id, address creator, string metadata, uint256 price);
    event NFTSold(uint256 id, address buyer, uint256 price);
    event NFTListed(uint256 id, uint256 price);
    event NFTUnlisted(uint256 id);

    function createNFT(string memory _metadata, uint256 _price) public {
        nftCount++;
        nfts[nftCount] = NFT(nftCount, msg.sender, msg.sender, _metadata, _price, false);
        userNFTs[msg.sender].push(nftCount);
        emit NFTCreated(nftCount, msg.sender, _metadata, _price);
    }

    function listNFT(uint256 _id, uint256 _price) public {
        require(nfts[_id].owner == msg.sender, "Not the owner");
        nfts[_id].price = _price;
        nfts[_id].forSale = true;
        emit NFTListed(_id, _price);
    }

    function unlistNFT(uint256 _id) public {
        require(nfts[_id].owner == msg.sender, "Not the owner");
        nfts[_id].forSale = false;
        emit NFTUnlisted(_id);
    }

    function buyNFT(uint256 _id) public payable {
        require(nfts[_id].forSale, "NFT not for sale");
        require(msg.value >= nfts[_id].price, "Insufficient funds");

        address previousOwner = nfts[_id].owner;
        payable(previousOwner).transfer(msg.value);

        nfts[_id].owner = msg.sender;
        nfts[_id].forSale = false;

        emit NFTSold(_id, msg.sender, msg.value);
    }
}

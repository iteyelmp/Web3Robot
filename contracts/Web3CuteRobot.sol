// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

import "./IW3RC3.sol";

interface IWeb3CuteRobotAccessories {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;

    function renderImage(uint256 typeId) external view returns (string memory);
}

contract Web3CuteRobot is ERC721, Ownable {
    using Strings for uint256;

    struct Accessory {
        address accessoryAddress;
        uint256 typeId;
    }

    uint256 constant public TOTAL_ROBOTS = 10000;

    string[10000] public names;
    string[10000] public descriptions;
    mapping(uint256 => Accessory[]) public accessories;

    uint256 public totalMinted = 0;

    IW3RC3 public w3q;

    constructor(address contractDataStorage_) ERC721("Web3CuteRobot", "Web3CuteRobot") {
        setContractDataStorageAddress(contractDataStorage_);
    }

    function setContractDataStorageAddress(address _contractDataStorageAddress) public onlyOwner {
        w3q = IW3RC3(_contractDataStorageAddress);
    }

    function mintRobot(address to, uint256 tokenId) external {
        require(totalMinted < TOTAL_ROBOTS, "Max CyberBrokers minted");
        _mint(to, tokenId);
        totalMinted++;
    }

    // REQUIRED for token contract
    function tokenURI(uint256 tokenId) public override view returns (string memory) {
        require(tokenId <= 10000, "Invalid tokenId");

        bytes memory json = abi.encodePacked(
            '{"name":"', names[tokenId], '",',
            '"description":"', descriptions[tokenId], '",',
            '"image":"data:image/svg+xml;base64,', renderImage(tokenId), '"}'
        );

        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(json)
        ));
    }

    function renderImage(uint256 tokenId) public view returns (string memory) {
        string memory access = '';
        uint256 accSize = accessories[tokenId].length;
        for (uint256 accIndex = 0; accIndex < accSize; accIndex++) {
            Accessory memory a = accessories[tokenId][accIndex];
            access = string(abi.encodePacked(
                access,
                '<image xlink:href="data:image/png;base64,',
                IWeb3CuteRobotAccessories(a.accessoryAddress).renderImage(a.typeId),
                '"/>'
            ));
        }

        bytes memory fileName = tokenId % 2 == 0 ? bytes('0.png') : bytes('1.png');
        (bytes memory bgPng,) = w3q.read(fileName);
        bytes memory svg = abi.encodePacked(
            '<svg viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
            '<image xlink:href="data:image/png;base64,', Base64.encode(bgPng), '"/>',
            access,
            '</svg>'
        );
        return Base64.encode(svg);
    }

    function setName(uint256 tokenId, string memory name) public onlyOwner {
        require(tokenId < 10000, "");
        names[tokenId] = name;
    }

    function setDescription(uint256 tokenId, string memory description) public onlyOwner {
        require(tokenId < 10000, "");
        descriptions[tokenId] = description;
    }

    function dress(uint256 tokenId, address accessoryAddr, uint256 typeId) external {
        require(ownerOf(tokenId) == msg.sender, "");

        IWeb3CuteRobotAccessories(accessoryAddr).safeTransferFrom(msg.sender, address(this), typeId, 1, "");
        Accessory memory acc = Accessory(accessoryAddr, typeId);
        accessories[tokenId].push(acc);
    }

    function undress(uint256 tokenId, address accessoryAddr, uint256 typeId) external {
        require(ownerOf(tokenId) == msg.sender, "");

        IWeb3CuteRobotAccessories(accessoryAddr).safeTransferFrom(address(this), msg.sender, typeId, 1, "");
        Accessory[] storage accs = accessories[tokenId];
        uint256 index = 0;
        bool found = false;
        for (; index < accs.length; index++) {
            Accessory memory acc = accs[index];
            if (acc.accessoryAddress == accessoryAddr && acc.typeId == typeId) {
                found = true;
                break;
            }
        }
        require(found, "can not find the specific accssory");
        accs[index] = accs[accs.length - 1];
        accs.pop();
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure returns (bytes4){
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure returns (bytes4){
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }
}

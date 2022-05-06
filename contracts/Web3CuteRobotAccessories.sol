// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "./IW3RC3.sol";

contract Web3CuteRobotAccessories is ERC1155, Ownable {
    mapping(uint256 => bytes) public typeNames;

    IW3RC3 public w3q;

    constructor(address _contractDataStorageAddress) ERC1155('') {
        w3q = IW3RC3(_contractDataStorageAddress);
    }

    function mintBatch(uint256[] memory typeId, uint256[] memory amounts) external onlyOwner {
        _mintBatch(owner(), typeId, amounts, "");
    }

    function setTypeName(uint256 typeId, bytes calldata name) external onlyOwner {
        typeNames[typeId] = name;
    }

    function uri(uint256 typeId) public view override returns (string memory) {
        bytes memory json = abi.encodePacked(
            '{"name":"', typeNames[typeId], '",',
            '"image":"data:image/png;base64,', renderImage(typeId), '"}'
        );
        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(json)
        ));
    }

    function renderImage(uint256 typeId) public view returns (string memory) {
        (bytes memory filePng,) = w3q.read(typeNames[typeId]);
        return Base64.encode(filePng);
    }
}

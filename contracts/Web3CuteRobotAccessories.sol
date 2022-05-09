// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Web3CuteRobotAccessories is ERC1155, Ownable {
    using Strings for uint256;

    address public w3q;
    string public gateway;

    mapping(uint256 => bytes) public typeNames;

    constructor(address _w3q, string memory _gateway) ERC1155('') {
        w3q = _w3q;
        gateway = _gateway;
    }

    function setW3q(address _w3q) public onlyOwner {
        w3q = _w3q;
    }

    function setGateway(string calldata _gateway) public onlyOwner {
        gateway = _gateway;
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
            '"image":"', renderImage(typeId), '"}'
        );
        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(json)
        ));
    }

    function renderImage(uint256 typeId) public view returns (string memory) {
        return string(abi.encodePacked(
                gateway,
                Strings.toHexString(uint256(uint160(w3q)), 20),
                '/',
                typeNames[typeId],
                '.png'
            ));
    }
}

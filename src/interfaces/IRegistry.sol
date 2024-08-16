pragma solidity ^0.8.0;

import {Proof} from "../common/Structs.sol";

interface IRegistry {
    function register(bytes calldata _initData) external payable;

    function updateState(bytes32 _state, bytes calldata _extra, Proof calldata _proof) external payable;

    function set(bytes32 _slot, bytes32 _value, bytes calldata _extra, Proof calldata _proof) external payable;

    // for setting the large value that cannot be stored within 32bytes
    function set(bytes32 _slot, bytes memory _value, bytes calldata _extra, Proof calldata _proof) external payable;

    function getState(address _owner) external view returns (bytes32);

    function get(address _owner, bytes32 _slot, bytes calldata _extra) external view returns (bytes32);

    function get(address _owner, bytes32 _slot, uint256 _length, bytes calldata _extra)
        external
        view
        returns (bytes memory);

    function get(address _owner, bytes32[] calldata _slots, bytes calldata _extra)
        external
        view
        returns (bytes32[] memory);
}

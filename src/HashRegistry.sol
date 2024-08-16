pragma solidity ^0.8.0;

import {IRegistry} from "./interfaces/IRegistry.sol";
import {Proof} from "./common/Structs.sol";

contract HashRegistry is IRegistry {
    error InitDataLengthError();

    mapping(address => mapping(bytes32 => bytes32)) public slot;

    mapping(address => bytes32) public state;

    function register(bytes calldata _initData) external payable {
        if (_initData.length % 64 != 0) {
            revert InitDataLengthError();
        }
        uint256 slots = _initData.length / 64;
        if (slots == 0) {
            revert InitDataLengthError();
        }
        for (uint256 i = 0; i < slots; i++) {
            bytes32 initSlot = bytes32(_initData[i * 32 + 0:i * 32 + 32]);
            bytes32 initValue = bytes32(_initData[i * 32 + 32:i * 32 + 64]);
            _set(msg.sender, initSlot, initValue);
        }
    }

    function updateState(bytes32 _state, bytes calldata _extra, Proof calldata _proof) external payable {
        // no-op
    }

    function getState(address _owner) external view returns (bytes32) {
        return state[_owner];
    }

    function _set(address _owner, bytes32 _slot, bytes32 _value) internal {
        slot[_owner][_slot] = _value;
        state[_owner] = keccak256(abi.encodePacked(state[_owner], _slot, _value));
    }

    function _set(address _owner, bytes32 _slot, bytes calldata _value) internal {
        // TODO need to deal with multi slot data
        state[_owner] = keccak256(abi.encodePacked(state[_owner], _slot, _value));
    }

    function set(bytes32 _slot, bytes32 _value, bytes calldata _extra, Proof calldata _proof) public payable {
        _set(msg.sender, _slot, _value);
    }

    // for setting the large value that cannot be stored within 32bytes
    function set(bytes32 _slot, bytes calldata _value, bytes calldata _extra, Proof calldata _proof) public payable {
        _set(msg.sender, _slot, _value);
    }

    function get(address _owner, bytes32 _slot, bytes calldata _extra) external view returns (bytes32) {
        return slot[_owner][_slot];
    }

    function get(address _owner, bytes32 _slot, uint256 _length, bytes calldata _extra)
        external
        view
        returns (bytes memory)
    {
        return abi.encodePacked(slot[_owner][_slot]);
    }

    function get(address _owner, bytes32[] calldata _slots, bytes calldata _extra)
        external
        view
        returns (bytes32[] memory)
    {
        bytes32[] memory slots = new bytes32[](_slots.length);
        for (uint256 i = 0; i < slots.length; i++) {
            slots[i] = slot[_owner][_slots[i]];
        }

        return slots;
    }
}

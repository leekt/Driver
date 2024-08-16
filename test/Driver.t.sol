pragma solidity ^0.8.0;

import {Driver} from "src/Driver.sol";
import {DriverLib} from "src/DriverLib.sol";
import {IRegistry} from "src/interfaces/IRegistry.sol";
import {Proof} from "src/common/Structs.sol";
import {IMPLEMENTATION_SLOT} from "src/common/Constants.sol";
import {StaticChecker} from "src/StaticChecker.sol";
import {Test} from "forge-std/Test.sol";

contract MockRegistry is IRegistry {
    mapping(address => mapping(bytes32 => bytes32)) public slot;

    function register(bytes calldata _initData) external payable {
        bytes32 initSlot = bytes32(_initData[0:32]);
        bytes32 initValue = bytes32(_initData[32:64]);
        slot[msg.sender][initSlot] = initValue;
    }

    function updateState(bytes32 _state, bytes calldata _extra, Proof calldata _proof) external payable {
        // no-op
    }

    function getState(address _owner) external view returns (bytes32) {
        // no-op
    }

    function set(bytes32 _slot, bytes32 _value, bytes calldata _extra, Proof calldata _proof) external payable {
        slot[msg.sender][_slot] = _value;
    }

    // for setting the large value that cannot be stored within 32bytes
    function set(bytes32 _slot, bytes calldata _value, bytes calldata _extra, Proof calldata _proof) external payable {
        slot[msg.sender][_slot] = bytes32(_value[0:32]);
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

contract MockImpl {
    uint256 public counter = 0;

    function hello() external view returns (string memory) {
        return "world";
    }

    function doSomething() external {
        counter++;
    }
}

contract DriverLibTest is Test {
    MockRegistry registry;
    MockImpl impl;
    StaticChecker checker;
    address constant CREATE2_PROXY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    function setUp() public {
        registry = new MockRegistry();
        impl = new MockImpl();
        (bool success, bytes memory ret) =
            CREATE2_PROXY.call(abi.encodePacked(uint256(0), hex"60033d8160093d39f35f5f5d"));
        checker = StaticChecker(address(bytes20(ret)));
    }

    function testSetGet() external {
        address addr = address(this);
        bytes32 slot = keccak256(abi.encodePacked("SLOT"));
        DriverLib._setTransient(slot, bytes32(bytes20(addr)));
        address res = DriverLib._toAddress(DriverLib._getTransient(slot));
        assertEq(res, addr);
    }

    function testDriverInit() external {
        Driver driver =
            new Driver(registry, checker, abi.encodePacked(IMPLEMENTATION_SLOT, bytes32(bytes20(address(impl)))));
        MockImpl instance = MockImpl(address(driver));
        assertEq(instance.hello(), "world");
        instance.doSomething();
    }
}

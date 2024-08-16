pragma solidity ^0.8.0;

import {DriverLib} from "./DriverLib.sol";
import {IMPLEMENTATION_SLOT} from "./common/Constants.sol";

contract StaticChecker {
    function check() external {
        DriverLib._setTransient(IMPLEMENTATION_SLOT, bytes32(bytes20(address(this))));
    }
}

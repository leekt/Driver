pragma solidity ^0.8.0;

import {DriverLib} from "./DriverLib.sol";
import {IRegistry} from "./interfaces/IRegistry.sol";
import {StaticChecker} from "./StaticChecker.sol";

/// @dev minimal proxy to program the storage and implementation
contract Driver {
    IRegistry public immutable registry;
    StaticChecker public immutable staticChecker;

    constructor(IRegistry _registry, StaticChecker _checker, bytes memory _initData) {
        registry = _registry;
        _registry.register(_initData);
        staticChecker = _checker;
    }

    fallback() external payable {
        address impl = DriverLib.getImplSelectorNow(registry, staticChecker, msg.sig);
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the impl
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}

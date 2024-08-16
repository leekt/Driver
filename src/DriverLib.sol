pragma solidity ^0.8.0;

import {StaticChecker} from "./StaticChecker.sol";
import {IRegistry} from "./interfaces/IRegistry.sol";
import {IMPLEMENTATION_SLOT} from "./common/Constants.sol";

library DriverLib {
    error ImplNotFound();

    function getImplSelectorNow(IRegistry _registry, StaticChecker _checker, bytes4 _selector)
        internal
        returns (address impl)
    {
        bytes32 slot = keccak256(abi.encodePacked(_selector, "DriverStorage"));
        impl = _toAddress(_getTransient(slot));

        if (impl != address(0)) {
            return impl;
        }

        impl = _toAddress(_getTransient(IMPLEMENTATION_SLOT));

        if (impl != address(0)) {
            return impl;
        }

        impl = _toAddress(_registry.get(address(this), slot, hex""));
        (bool notStatic,) = address(_checker).call{gas: 104}(hex"");

        if (impl != address(0)) {
            if (notStatic) {
                _setTransient(slot, bytes32(bytes20(impl)));
            }
            return impl;
        }

        // fetch the default impl when there is no other implementation hooked up with the selector
        impl = _toAddress(_registry.get(address(this), IMPLEMENTATION_SLOT, hex""));

        if (impl == address(0)) {
            revert ImplNotFound();
        }
        if (notStatic) {
            // checker.check does minimal tstore to check if this is static call or not
            _setTransient(IMPLEMENTATION_SLOT, bytes32(bytes20(impl)));
        }
    }

    function _setTransient(bytes32 slot, bytes32 value) internal {
        assembly {
            tstore(slot, value)
        }
    }

    function _getTransient(bytes32 slot) internal view returns (bytes32 value) {
        assembly {
            value := tload(slot)
        }
    }

    function _toAddress(bytes32 value) internal pure returns (address) {
        return address(bytes20(value));
    }
}

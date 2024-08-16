pragma solidity ^0.8.0;

import {DriverLib} from "./DriverLib.sol";
import {IMPLEMENTATION_SLOT} from "./common/Constants.sol";

contract StaticChecker {
    constructor() {}
}

/**
 * --------------------------------------------------------------------------+
 * CREATION (9 bytes)                                                        |
 * --------------------------------------------------------------------------|
 * Opcode     | Mnemonic          | Stack     | Memory                       |
 * --------------------------------------------------------------------------|
 * 60 runSize | PUSH1 runSize     | r         |                              |
 * 3d         | RETURNDATASIZE    | 0 r       |                              |
 * 81         | DUP2              | r 0 r     |                              |
 * 60 offset  | PUSH1 offset      | o r 0 r   |                              |
 * 3d         | RETURNDATASIZE    | 0 o r 0 r |                              |
 * 39         | CODECOPY          | 0 r       | [0..runSize): runtime code   |
 * f3         | RETURN            |           | [0..runSize): runtime code   |
 * --------------------------------------------------------------------------|
 * RUNTIME (3 bytes)                                                        |
 * --------------------------------------------------------------------------|
 * Opcode  | Mnemonic       | Stack                  | Memory                |
 * --------------------------------------------------------------------------|
 *                                                                           |
 * ::: keep some values in stack ::::::::::::::::::::::::::::::::::::::::::: |
 * 5f      | push0          | 0                      |                       |
 * 5f      | push0          | 0 0                    |                       |
 * 5d      | tstore         |                        |                       |
 *
 *             0x60033d8160093d39f35f5f5d
 */

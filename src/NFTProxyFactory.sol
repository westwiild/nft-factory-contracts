// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {INFTImplementation} from "./interfaces/INFTImplementation.sol";

contract NFTProxyFactory {
    /// @notice The implementation contract address
    address public immutable IMPLEMENTATION_CONTRACT;
    /// @notice The array of proxy addresses
    address[] public proxies;

    event ProxyDeployed(address indexed proxy, string name, string symbol);

    error NFTProxyFactoryInvalidImplementationContract();

    /**
     * @dev Initializes the contract by setting the implementation contract address.
     * @param _implementationContract The address of the implementation contract.
     */
    constructor(address _implementationContract) {
        if (_implementationContract == address(0)) {
            revert NFTProxyFactoryInvalidImplementationContract();
        }
        IMPLEMENTATION_CONTRACT = _implementationContract;
    }

    /**
     * @dev Deploys a clone of the implementation contract.
     * @param name The name of the token collection.
     * @param symbol The symbol of the token collection.
     * @return The address of the deployed clone.
     */
    function deployClone(string memory name, string memory symbol) external returns (address) {
        // convert the address to 20 bytes
        bytes20 implementationContractInBytes = bytes20(IMPLEMENTATION_CONTRACT);
        //address to assign a cloned proxy
        address proxy;

        // as stated earlier, the minimal proxy has this bytecode
        // <3d602d80600a3d3981f3363d3d373d3d3d363d73><address of implementation contract><5af43d82803e903d91602b57fd5bf3>

        // <3d602d80600a3d3981f3> == creation code which copies runtime code into memory and deploys it

        // <363d3d373d3d3d363d73> <address of implementation contract> <5af43d82803e903d91602b57fd5bf3> == runtime code that makes a delegatecall to the implentation contract

        assembly {
            /*
            reads the 32 bytes of memory starting at the pointer stored in 0x40
            In solidity, the 0x40 slot in memory is special: it contains the "free memory pointer"
            which points to the end of the currently allocated memory.
            */
            let clone := mload(0x40)
            // store 32 bytes to memory starting at "clone"
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)

            /*
              |              20 bytes                |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
                                                      ^
                                                      pointer
            */
            // store 32 bytes to memory starting at "clone" + 20 bytes
            // 0x14 = 20
            mstore(add(clone, 0x14), implementationContractInBytes)

            /*
              |               20 bytes               |                 20 bytes              |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe
                                                                                              ^
                                                                                              pointer
            */
            // store 32 bytes to memory starting at "clone" + 40 bytes
            // 0x28 = 40
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            /*
            |                 20 bytes                  |          20 bytes          |           15 bytes          |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73b<implementationContractInBytes>5af43d82803e903d91602b57fd5bf3 == 45 bytes in total
            */

            // create a new contract
            // send 0 Ether
            // code starts at the pointer stored in "clone"
            // code size == 0x37 (55 bytes)
            proxy := create(0, clone, 0x37)
        }

        // Update state before external call
        proxies.push(proxy);

        // Call initialization
        INFTImplementation(proxy).initialize(name, symbol, msg.sender);

        emit ProxyDeployed(proxy, name, symbol);

        return proxy;
    }
}

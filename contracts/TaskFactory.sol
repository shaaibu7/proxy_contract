// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./TaskEscrow.sol";

contract TaskFactory is Initializable {
    using Clones for address;

    address public taskEscrowImplementation;
    address[] public tasks;

    event TaskCreated(address indexed taskAddress, address indexed creator);

    function initialize(address _taskEscrowImpl) public initializer {
        taskEscrowImplementation = _taskEscrowImpl;
    }

    function createTask(
        string memory _title,
        string memory _description,
        string memory _category,
        uint256 _deadline
    ) external payable returns (address) {
        require(msg.value > 0, "Reward cannot be empty.");

        address clone = taskEscrowImplementation.clone();
        address payable payableClone = payable(clone);
        TaskEscrow(payableClone).initialize(
            address(this),
            msg.sender,
            _title,
            _description,
            _category,
            msg.value,
            _deadline
        );

        tasks.push(clone);
        (bool success, ) = payable(clone).call{value: msg.value}("");

        emit TaskCreated(clone, msg.sender);
        return clone;
    }

    function getAllTasks() external view returns (address[] memory) {
        return tasks;
    }
}

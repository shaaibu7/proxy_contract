// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TaskEscrow is Initializable {
    address public factory;
    address public taskPoster;
    address public taskCompleter;
    string public title;
    string public description;
    string public category;
    uint256 public reward;
    uint256 public deadline;
    bool public isCompleted;
    bool public isDisputed;

    enum Status { OPEN, ASSIGNED, COMPLETED, DISPUTED }
    Status public status;

    event TaskAssigned(address indexed completer);
    event TaskCompleted();
    event DisputeRaised();
    event FundsReleased(address indexed recipient, uint256 amount);

    modifier onlyFactory() {
        require(msg.sender == factory, "Caller is not factory");
        _;
    }

    modifier onlyTaskPoster() {
        require(msg.sender == taskPoster, "Only task poster can call");
        _;
    }

    modifier onlyTaskCompleter() {
        require(msg.sender == taskCompleter, "Only task completer can call");
        _;
    }

    function initialize(
        address _factory,
        address _taskPoster,
        string memory _title,
        string memory _description,
        string memory _category,
        uint256 _reward,
        uint256 _deadline
    ) public initializer {
        factory = _factory;
        taskPoster = _taskPoster;
        title = _title;
        description = _description;
        category = _category;
        reward = _reward;
        deadline = block.timestamp + _deadline;
        status = Status.OPEN;
    }

    function assignTask(address _completer) external onlyTaskPoster {
        require(status == Status.OPEN, "Task already assigned/completed");
        taskCompleter = _completer;
        status = Status.ASSIGNED;
        emit TaskAssigned(_completer);
    }

    function submitWork() external onlyTaskCompleter {
        require(status == Status.ASSIGNED, "Task not assigned");
        isCompleted = true;
        status = Status.COMPLETED;
        emit TaskCompleted();
    }

    function releasePayment() external onlyTaskPoster {
        require(status == Status.COMPLETED, "Task not completed");
        payable(taskCompleter).transfer(reward);
        emit FundsReleased(taskCompleter, reward);
    }

    function raiseDispute() external {
        require(msg.sender == taskPoster || msg.sender == taskCompleter, "Unauthorized");
        isDisputed = true;
        status = Status.DISPUTED;
        emit DisputeRaised();
    }

    function resolveDispute(address _winner) external {
        require(status == Status.DISPUTED, "No active dispute");
        (bool success, )= payable(_winner).call{value: reward}("");
        status = Status.COMPLETED;
    }

    receive() external payable {}
}

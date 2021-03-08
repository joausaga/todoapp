pragma solidity ^0.4.24;

import "@aragon/os/contracts/lib/math/SafeMath.sol";
import "@aragon/os/contracts/apps/AragonApp.sol";

contract TodoApp is AragonApp{
    using SafeMath for uint;   
    
    // roles
    bytes32 constant public ADD_TASK = keccak256("ADD_TASK");
    bytes32 constant public DEL_TASK = keccak256("DEL_TASK");
    bytes32 constant public UPD_TASK = keccak256("UPD_TASK");
    bytes32 constant public GET_TASK = keccak256("GET_TASK");

    // events
    event AddTask(address indexed entity, uint taskId);
    event DelTask(address indexed entity, uint taskId);
    event UpdTask(address indexed entity, uint taskId);

    // state
    enum Priority {
        High, Medium, Low
    }
    struct Task {
        uint id;
        string name;
        uint64 dueDate;
        bool exists;
        Priority priority;
    }
    mapping(address => mapping(uint => Task)) public tasks;
    mapping(address => uint) public numTasks;

    function initialize() public onlyInit {
        initialized();
    }

    modifier taskExists(uint _taskId) {
        require(tasks[msg.sender][_taskId].exists, "TaskId does not exist");
        _;
    }

    modifier validPriority(uint _idxPriority) {
        require(_idxPriority <= uint(Priority.Low), "Invalid priority index");
        _;
    }

    /**
    * @notice Add task 
    * @param _taskName name of task
    * @param _taskDueDate due date of task
    * @param _idxPriority index of task (0=High, 1=Medium, 2=Low)
    */
    function addTask(string _taskName, uint64 _taskDueDate, uint _idxPriority) 
        auth(ADD_TASK) external validPriority(_idxPriority) 
    {
        uint taskId = numTasks[msg.sender];
        Task memory newTask = Task({
            id: taskId,
            name: _taskName,
            dueDate: _taskDueDate,
            exists: true,
            priority: Priority(_idxPriority)
        });
        tasks[msg.sender][taskId] = newTask;
        numTasks[msg.sender] = numTasks[msg.sender].add(1);

        emit AddTask(msg.sender, taskId);
    }

    /**
    * @notice Delete a task given by taskId 
    * @param _taskId id of task
    */
    function delTask(uint _taskId) auth(DEL_TASK) external {
        uint lastTask = numTasks[msg.sender].sub(1);
        tasks[msg.sender][_taskId] = tasks[msg.sender][lastTask];
        numTasks[msg.sender] = numTasks[msg.sender].sub(1);
        emit DelTask(msg.sender, _taskId);
    }

    /**
     * @notice Edit a task given by taskId 
     * @param _taskId id of task
     * @param _taskName name of task
     * @param _taskDueDate due date of task
     * @param _idxPriority index of task (0=High, 1=Medium, 2=Low)
     */
    function updTask(uint _taskId, string _taskName, uint64 _taskDueDate, 
        uint _idxPriority) auth(UPD_TASK) external taskExists(_taskId) 
        validPriority(_idxPriority) 
    {
        Task memory updatedTask = Task({
            id: _taskId,
            name: _taskName,
            dueDate: _taskDueDate,
            exists: true,
            priority: Priority(_idxPriority)
        });
        tasks[msg.sender][_taskId] = updatedTask;
        emit UpdTask(msg.sender, _taskId);
    }

    function getTask(uint _taskId, address _entity) auth(GET_TASK) 
        external taskExists(_taskId) 
        view returns (string name, uint dueDate, bool exists, uint priority) 
        
    {
        Task memory task = tasks[_entity][_taskId];
        name = task.name;
        dueDate = task.dueDate;
        exists = task.exists;
        if (task.priority == Priority.Low) {
            priority = uint(Priority.Low);
        }
        else if (task.priority == Priority.Medium) {
            priority = uint(Priority.Medium);
        } else {
                priority = uint(Priority.High);
        }
    }
}

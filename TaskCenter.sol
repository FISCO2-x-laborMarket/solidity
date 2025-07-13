pragma solidity >=0.4.24 <0.6.11;
import "./Task.sol";
import "./UUID.sol";

contract TaskCenter {
    // 这个合约只是存储所有的Task
    // 提供功能: 1.修改Task状态
    //          2.带偏移量查询
    //          3.按照后端调用去做hash，保证分时段一致
    address public owner;
    mapping(uint => Task) private taskMap;  // 任务ID到任务实例的映射,当前在线的合约
    uint[] private taskIds;               // 所有任务ID列表
    mapping (bytes32=>bool) public  IdList;
    bool private lock;//计算哈希时候需要上锁
    
    bytes32[] public hashList;//各个时段的哈希集合
    bytes32 public currentHash;//当前时段的哈希
    uint[]public hashIndex;// 每次hash对应到的数组list的index

    Task[] public Tasks;// 历史所有合约
    event TaskCreated(uint taskId, address taskAddress);
    event TaskRemoved(uint taskId);
    event StatusUpdated(uint taskId, int newCode);
    event IDRegistered(bytes32 idHash);
    UUID private  uuids;
    constructor(address _owner) public {
        owner = _owner;
        uuids=new UUID();
    }


    // 创建任务
    function createTask(uint _TaskId, address _master, uint _amount, int32 _initStatus, string _other, int32 _Type, string _Tiltle) public returns (address) {
        require(!lock,"now is attending other job please wait");
        Task newTask = new Task(_master, _TaskId, _amount, _initStatus,_other,owner,_Type,_Tiltle);
        taskMap[_TaskId] = newTask;
        taskIds.push(_TaskId);
        emit TaskCreated(_TaskId, address(newTask));
        return address(newTask);
    }

    // 获取任务实例
    function getTask(uint _taskId) public view returns (Task) {
        require(address(taskMap[_taskId]) != address(0), "Task not exist");
        return taskMap[_taskId];
    }

    // 移除任务,改变状态码即可
    function removeTask(uint _taskId) public {
        require(address(taskMap[_taskId]) != address(0), "Task not exist");
        if (msg.sender!=owner){
            require(taskMap[_taskId].MasterAddress() == msg.sender, "Permission denied");
        }
        // delete taskMap[_taskId];
        taskMap[_taskId].ChangeStatsCode(-1);//-1为状态码
        emit TaskRemoved(_taskId);// 数据库同步做软删除
    }
    // 注册ID在生成前预调用
    function RegisterId(uint id ) external {
        bytes32 idHash = keccak256(abi.encodePacked(id));
        require(!IdList[idHash], "ID already exists");
        
        IdList[idHash] = true;
        emit IDRegistered(idHash);
    }
    //
    // function AddReceiverAddress(address ReceiverAddress,uint _taskId)external  {
    //     require(address(taskMap[_taskId]) != address(0), "Task not exist");
    //     taskMap[_taskId].AddReceiver(ReceiverAddress);
    // }

    function calculateHash()public returns(bytes32) {
        lock=true;
        if(hashIndex.length==0){
            currentHash=sha256(abi.encode(Tasks));
            hashList.push(currentHash);
            hashIndex.push(Tasks.length-1);
        }else {
        bytes memory encoded = "";
        uint startIndex = hashIndex[hashIndex.length-1];
        // 遍历从startIndex到数组末尾
        for (uint i = startIndex; i < Tasks.length; i++) {
            // 对每个元素进行编码并连接
            encoded = abi.encodePacked(encoded, Tasks[i]);
        }
        currentHash=sha256(encoded);
        hashList.push(currentHash);
        hashIndex.push(Tasks.length-1);
        }
        lock=false;
        return(currentHash);
    }

}
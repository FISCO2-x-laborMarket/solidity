pragma solidity>=0.4.24 <0.6.11;
import "./Log.sol";
contract Task{
    // 包含字段: TaskId(使用./UUID.sol中的UUID合约的uuid4()函数)类型为string
    //          MasterAddress //类型为address
    //          ReceiverAddress //类型为address
    //          changeLog      //类型为string[]
    //          Amount          //类型为uint
    //          CreateTime      //block.timestamp
    //          StatusCode      // 类型为int
    //          TaskHash        //类型为bytes32包含除了ChangeLog,StatusCode和ReceiverAddress外的其他内容的哈希(也不包含ReceivedHash和LogHash)
    //          ReceivedHash     //类型为bytes32包含除了ChangeLog,StatusCode外的其他内容哈希(也不包含TaskHash和LogHash)
    //          LogHash         //类型为bytes32仅为ChangeLog的Hash(也不包含ReceivedHash和LogHash)
    //注意: log的string是一个jsonStr,大概格式如下:
    //{"log":"操作内容","time":block.timestamp,index:int}
    //包含函数以及功能(你需要按照各个函数功能选择性的更新三个Hash值): 
    //      构造函数: 输入MasterAddress,TaskId,Amount,StatuCode,你需要计算某些当前的哈希值
    //      RemoveReceiver: 无输入需要检查是否是由合约的Master调用
    //      ChangeStatusCode: 输入:int,需要检测是否为master，并且将内容记录到log中
    uint public TaskId;
    address public MasterAddress;
    address public ReceiverAddress;
    Log[] public changeLog;
    uint public Amount;
    uint public CreateTime;
    int32 public StatusCode;
    string public Other;
    int32  public Type;// Task类型
    string public Title;// 标题

    bytes32 public TaskHash;
    bytes32 public ReceivedHash;
    bytes32 public LogHash;
    address private ownerAddress;
    event Debug(string );

    constructor(address _masterAddress,uint _taskId,uint _amount,int32 _statusCode,string _other,address _ownerAddress,int32 _Type,string _Title) public {
        MasterAddress = _masterAddress;
        TaskId = _taskId;
        Amount = _amount;
        StatusCode = _statusCode;
        CreateTime = block.timestamp;
        Other=_other;
        ownerAddress=_ownerAddress;
        Type=_Type;
        Title=_Title;

        // 初始化日志（索引0）
        _addLogEntry("Task created");
        
        // 初始化哈希
        _updateAllHashes();
    }

    function getTaskHashStr() public view  returns (string memory) {
        return HashBytesToStr(TaskHash);
    }

    function getRecviedHashStr() public view  returns (string memory) {
        return HashBytesToStr(ReceivedHash);
    }


    function getLogHashStr() public view returns (string memory) {
    
        return (HashBytesToStr(LogHash));
    }

    function AddLog(string _action) public {
        require(msg.sender == MasterAddress||msg.sender== ReceiverAddress, "Only participant can operate");
        changeLog.push(new Log(_action,int(changeLog.length),int(2)));
    }
    

function HashBytesToStr(bytes32 _hash) internal pure returns (string memory) {
    // 用于存储最终的十六进制字符串（不含0x前缀）
    bytes memory hexChars = new bytes(64);

    for (uint i = 0; i < 32; i++) {
        byte b = _hash[i];
        uint8 firstNibble = uint8(b) / 16;
        uint8 secondNibble = uint8(b) % 16;
        // 将每个字节转换为两个十六进制字符
        hexChars[i*2] = hexChar(firstNibble);
        hexChars[i*2+1] = hexChar(secondNibble);
    }

    // 创建一个新bytes数组来包含"0x"前缀
    bytes memory finalHex = new bytes(hexChars.length + 2);
    finalHex[0] = '0';
    finalHex[1] = 'x';

    for(uint j = 0; j < hexChars.length; j++) {
        finalHex[j + 2] = hexChars[j];
    }

    return string(finalHex);
}
  // 辅助函数：将4位二进制数转换为相应的十六进制字符
    function hexChar(uint8 _byte) internal pure   returns (byte) {
        // 如果小于10，则返回'0'到'9'之间的一个字符；否则返回'a'到'f'之间的一个字符
        return (_byte < 10) ? byte(_byte + 48) : byte(_byte + 87); // 'a'的ASCII码是97, 所以需要加87
    }


    // 移除接收者
    function RemoveReciver() public {
        require(msg.sender == MasterAddress, "Only master can operate");
        ReceiverAddress = address(0);
        
        _addLogEntry("Receiver removed");
        _updateReceivedHash(); // 更新相关哈希
        _updateLogHash();
    }
    // 新增接收者
    function AddReciver(address ReceiverAdd) public {
        require(msg.sender == MasterAddress, "Only master can operate");
        ReceiverAddress = ReceiverAdd;
        
        _addLogEntry("Receiver Update");
        _updateReceivedHash(); // 更新相关哈希
        _updateLogHash();
    }


    // 修改状态码
    function ChangeStatuCode(int32 _newCode) public {
        require(msg.sender == MasterAddress, "Only master can operate");
        StatusCode = _newCode;
        
        _addLogEntry("Status changed");
        _updateLogHash();
    }

    // 哈希更新逻辑
    function _updateTaskHash() internal {
        TaskHash = sha256(abi.encodePacked(
            MasterAddress,
            TaskId,
            Amount,
            Type,
            CreateTime,
            Other
        ));
    }

    function _updateReceivedHash() internal {
        ReceivedHash = sha256(abi.encodePacked(
            MasterAddress,
            TaskId,
            Amount,
            Type,
            CreateTime,
                ReceiverAddress,
            Other
        ));
    }

    function _updateLogHash() internal {
        LogHash = sha256(abi.encodePacked(changeLog));
    }

    function _updateAllHashes() internal {
        _updateTaskHash();
        _updateReceivedHash();
        _updateLogHash();
    }

    // 日志生成逻辑
    function _addLogEntry(string memory _action) internal {
        changeLog.push(new Log(_action,int(changeLog.length),int(1)));
    }

    // 类型转换工具
    function _uintToString(uint _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        uint j = _i;
        uint len;
        while (j != 0) { len++; j /= 10; }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    } 

    function _intToString(int _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        bool negative = _i < 0;
        uint i = uint(negative ? -_i : _i);
        uint len;
        for (uint j = i; j != 0; j /= 10) { len++; }
        if (negative) len++;
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0) {
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }
        if (negative) bstr[0] = '-';
        return string(bstr);
    }
    // 新增函数：获取Log地址的JSON数组
    function getLogs() public view returns (string memory) {
        string memory json = "[";
        for (uint i = 0; i < changeLog.length; i++) {
            address logAddr = address(changeLog[i]);
            string memory addrStr = _addressToString(logAddr);
            if (i == 0) {
                json = string(abi.encodePacked(json, '"', addrStr, '"'));
            } else {
                json = string(abi.encodePacked(json, ', "', addrStr, '"'));
            }
        }
        json = string(abi.encodePacked(json, "]"));
        return json;
    }

    // 辅助函数：将地址转换为字符串
    function _addressToString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
}
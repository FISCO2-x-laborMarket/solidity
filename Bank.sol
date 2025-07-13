pragma solidity>=0.4.24 <0.6.11;
import "./Transaction.sol";
import "./UUID.sol";
// 提供功能:
/**
1. 获取账户流水(AccountTrasaction) done
2. 转账(Transfer) done
3. 根据指定TransectionHash查找Transaction
4. 创建余额 done


 封禁用户(feature)
**/
contract Bank {
    // UUID private  UUIDUtil;
    address public  owner;// 可透支资产，其他用户均不可透支
    uint TimeLock; // 时间锁，限制高流量转账
    //mapping 的address均为 Transaction的地址
    uint256 received;
    UUID private  uuids;

    mapping (address => int64) private  balance; // 账户余额

    mapping (address=> Transaction[] )private accountList;// 账户流水

    mapping (bytes32 => Transaction ) private AccountTransaction;// 查询单笔交易

    mapping (address => Transaction[]) private CreateTransactions;// 创建余额交易，数据库做同步，这里记录原始数据

    mapping (address=>Transaction) private AddressToTransaction;// 查询
    mapping(address => bool) private isBanned; // 封禁状态
    mapping(address=> uint)private nextTransferTime;// 下一次允许转账的时间戳

    event TransferEvent(address from, address to, uint64 amount);// 交易事件 同步至数据库
    event BanUserEvent(address user, bool status);// ban掉用户事件
    event ForceTransEvent(address from, address to, uint64 amount);

    constructor(address _owner,uint _timeLock) public {
        owner=_owner;
        TimeLock=_timeLock;
        uuids=new UUID();
    }
    function GetTransactionByHash(bytes32 hash)public view returns(Transaction){
        return (AccountTransaction[hash]);
    }


    function getAccountTransaction(address userAdd) public view returns (Transaction[]) {
        require(userAdd != address(0), "Invalid Address");
        return accountList[userAdd];
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    modifier notBanned() {
        require(!isBanned[msg.sender], "This account is banned");
        _;
    }
    function transfer(address recipient, uint64 amount,string other) public returns (address)  {
        require(!isBanned[msg.sender], "This account is banned");
        if( msg.sender!=owner){
            // require(uint64(balance[msg.sender]) >= amount, "Insufficient funds");
            require(recipient != address(0), "Invalid Address");
            require(!isBanned[recipient],"targetAccountIs Banned");
            require(nextTransferTime[msg.sender]<=block.timestamp,"Frequent transactions");
        }
        // 确保发送金额不大于当前余额
        balance[msg.sender] -= int64(amount);
        balance[recipient] += int64(amount);
        nextTransferTime[msg.sender]=block.timestamp+TimeLock;// 更新下次交易时间戳
        string memory Id =  uuids.uuid4();

        Transaction newTransaction =new Transaction(msg.sender, recipient, amount,Id,other);
        AccountTransaction[newTransaction.TransactionHash()] = newTransaction;
        accountList[msg.sender].push(newTransaction);
        // // 更新账户流水
        accountList[recipient].push(newTransaction);
        AddressToTransaction[address(newTransaction)]=newTransaction;
        emit TransferEvent(msg.sender, recipient, amount);
        return (address(newTransaction));
    }
    function banUser(address user, bool status) public onlyOwner {
        isBanned[user] = status;
        emit BanUserEvent(user, status);
    }
    function getSingleTransaction(address add)public view returns(Transaction) {

        return AddressToTransaction[add];
    }

    function Payed()public payable {
        received +=msg.value;
    }
    function getTransactionUser()public view returns(address,address){
        return (msg.sender,owner);
    }
    function ForceTransaction(address from,address recipient, uint64 amount)public {
        // require(msg.sender==owner,"only owner can do it");// 检测是否是合约所属者，只有合约所属者才能调用，开发先注释掉
        require(uint64(balance[msg.sender]) >= amount, "Insufficient funds");
        require(recipient != address(0), "Invalid Address");
        require(from != address(0), "Invalid Address");
         // 确保发送金额不大于当前余额
        balance[msg.sender] -= int64(amount);
        balance[recipient] += int64(amount);
        nextTransferTime[msg.sender]=block.timestamp+TimeLock;// 更新下次交易时间戳
        string memory Id =  uuids.uuid4();

        Transaction newTransaction =new Transaction(from, recipient, amount,Id,"Force Transaction");
        AccountTransaction[newTransaction.TransactionHash()] = newTransaction;
        accountList[from].push(newTransaction);
        // 更新账户流水
        accountList[recipient].push(newTransaction);
        AddressToTransaction[address(newTransaction)]=newTransaction;
        emit ForceTransEvent(from, recipient, amount);
    }
//0xAB8483f64d9c6D1EcF9B849aE677DD3315835CB2
//0x5f121ba72a3829af2fad8cb81e1f7c5bce4cadf57631659c752e695e02341fe4

}
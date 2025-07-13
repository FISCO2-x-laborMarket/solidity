# Bank.sol

介绍:

弱中心化类型应用型智能合约，和ERC20合约相似，但是授权相关内容未完成，整体包含内容：转账，查询余额，封禁账户等功能

构造函数:

```solidity
constructor(address _owner,uint _timeLock) public {}
```

参数说明:
> _owner: 合约管理员
>
> _timeLock: 转账后需要等待的时间戳，防止短时间内大量转账

主要应用函数:

1. 转账函数transfer:

```solidity
function transfer(address recipient, uint64 amount,string other) public returns (address)  {}
```
参数说明:
> recipient: 收款方
>
> amount: 转账金额
>
> other: 其他信息(转账附语)

返回值:
> 收据地址(Transaction.sol)
>
特别说明:

在如下情况中会直接抛出错误: 1.转账账户没token 2. 转账时间间未到 3. 转账账户被封禁
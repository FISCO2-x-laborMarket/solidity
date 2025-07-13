pragma solidity>=0.4.24 <0.6.11;
contract Transaction {
    address public  from;
    address public to;
    uint64 public value;
    uint256 public blockTime;
    string public TransactionId;// UUID
    bytes32 public TransactionHash;//
    string public other;
    constructor(address _form,address _to,uint64 _value,string memory _TransactionId,string _other) public{
        from=_form;
        to=_to;
        value=_value;
        TransactionId=_TransactionId;
        blockTime=block.timestamp;
        other=_other;
        TransactionHash =sha256(abi.encode(from,to,value,TransactionId,blockTime,other));
    }
    function getTransactionHashStr() public view returns (string memory) {
        // 用于存储最终的十六进制字符串
        bytes memory hexChars = new bytes(64);

        for (uint i = 0; i < 32; i++) {
            uint8 tempByte = uint8(TransactionHash[i]);
            // 将每个字节转换为两个十六进制字符
            hexChars[i*2] = byte(hexChar(tempByte / 16));
            hexChars[i*2+1] = byte(hexChar(tempByte % 16));
        }

        return string(abi.encode("0x",string(hexChars)));
    }

    // 辅助函数：将4位二进制数转换为相应的十六进制字符
    function hexChar(uint8 _byte) internal pure returns (byte) {
        // 如果小于10，则返回'0'到'9'之间的一个字符；否则返回'a'到'f'之间的一个字符
        return (_byte < 10) ? byte(_byte + 48) : byte(_byte + 87); // 'a'的ASCII码是97, 所以需要加87
    }
    function toString() public view returns (string memory) {
    bytes memory json = abi.encodePacked(
        '{',
        '"from": "', addressToString(from), '",',
        '"to": "', addressToString(to), '",',
        '"value": ', uintToString(value), ',',
        '"blockTime": ', uintToString(blockTime), ',',
        '"TransactionId": "', TransactionId, '",',
        '"TransactionHash": "', getTransactionHashStr(), '",',
        '"other": "', other, '"',
        '}'
    );
    return (string(json));
}

// 辅助函数：将地址转换为字符串
function addressToString(address _addr) internal pure returns (string memory) {
    bytes32 _value = bytes32(uint256(_addr));
    bytes memory alphabet = "0123456789abcdef";
    bytes memory str = new bytes(42);
    str[0] = '0';
    str[1] = 'x';
    for (uint i = 0; i < 20; i++) {
        str[2+i*2] = alphabet[uint(uint8(_value[i + 12] >> 4))];
        str[3+i*2] = alphabet[uint(uint8(_value[i + 12] & 0x0f))];
    }
    return string(str);
}

// 辅助函数：将uint转换为字符串
function uintToString(uint _i) internal pure returns (string memory) {
    if (_i == 0) {
        return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
        len++;
        j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len;
    while (_i != 0) {
        k = k-1;
        uint8 temp = (48 + uint8(_i - _i / 10 * 10));
        bytes1 b1 = bytes1(temp);
        bstr[k] = b1;
        _i /= 10;
    }
    return string(bstr);
}

    
}





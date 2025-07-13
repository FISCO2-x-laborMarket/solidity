pragma solidity>=0.4.24 <0.6.11;
contract Log{
    address public  Operator;// 操作人
    string public LogAction ;
    int public Index;
    uint  public  TimeStamp;
    int public  Type;// 1: System 2: User
    constructor(string _LogAction,int _Index,int _Type)public {
        LogAction=_LogAction;
        Index=_Index;
        Operator =msg.sender;
        TimeStamp=uint(block.timestamp);
        Type=_Type;
    }

    function toJson()public view returns (string memory){
        return(string(abi.encodePacked(
            '{"log":"', LogAction,
            '","time":', _uintToString(TimeStamp),
            ',"index":', _intToString(Index),
            ',"opreator":',addressToString(Operator),
            ',"type":', _intToString(Type),
            '}'
        )));
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
}
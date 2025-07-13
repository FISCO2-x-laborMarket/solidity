pragma solidity>=0.4.24 <0.6.11;

contract HexUtil{
    function CalculateHash(string data)public pure returns (bytes32){
       bytes32 res =sha256(abi.encodePacked(data));
       return (res);
    }


    function bytes32ToHex(bytes32 _data) public pure returns (string memory) {
        // 用于存储最终的十六进制字符串
        bytes memory hexChars = new bytes(64);
        
        for (uint i = 0; i < 32; i++) {
            uint8 tempByte = uint8(_data[i]);
            
            // 将每个字节转换为两个十六进制字符
            hexChars[i*2] = byte(hexChar(tempByte / 16));
            hexChars[i*2+1] = byte(hexChar(tempByte % 16));
        }
        
        return string(hexChars);
    }

    // 辅助函数：将4位二进制数转换为相应的十六进制字符
    function hexChar(uint8 _byte) internal pure returns (byte) {
        // 如果小于10，则返回'0'到'9'之间的一个字符；否则返回'a'到'f'之间的一个字符
        return (_byte < 10) ? byte(_byte + 48) : byte(_byte + 87); // 'a'的ASCII码是97, 所以需要加87
    }

}
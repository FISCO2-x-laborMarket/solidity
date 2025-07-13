pragma solidity>=0.4.24 <0.6.11;
contract UUID {

    // Below is a random semiprime number with 256 bits
    uint constant pq = 98686309634733686614376257523655700182914516739573612855898430044873713577331;
    uint lastCallTime = 0;
    uint private nonce;
    /// @notice Generate UUID
    /// @return UUID of 16bytes
    function uuidgen() internal  returns (bytes memory){
        bytes1[16] memory seventhByteMembers = [bytes1(0x40), bytes1(0x41), bytes1(0x42), bytes1(0x43), bytes1(0x44),bytes1(0x45),bytes1(0x46),bytes1(0x47),bytes1(0x48),bytes1(0x49),bytes1(0x4a),bytes1(0x4b),bytes1(0x4c),bytes1(0x4d),bytes1(0x4e),bytes1(0x4f)];
        bytes16 uuidData = bytes16(keccak256(abi.encodePacked(
                                msg.sender,
                                pq ^ (block.timestamp + 16),
                                nonce
                                )));
        
        bytes memory uuid = abi.encodePacked(uuidData);
        if(lastCallTime==block.timestamp){
            nonce++;
        }else {
            lastCallTime=block.timestamp;// 防止重复计算导致ID重复
            nonce=(block.timestamp%3217)%(block.timestamp%2771);
        }
        
        uuid[6]=seventhByteMembers[(block.timestamp+16)/2%16];
        return uuid;
    
    }


    function _bytestostring(bytes memory buffer) internal pure returns (string memory) {

        // Fixed buffer size for hexadecimal conversion
        bytes memory converted = new bytes(buffer.length * 2);

        bytes memory _base = "0123456789abcdef";
        uint i =0 ;
        uint buffLength = buffer.length;
        for (i; i < buffLength; ++i) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        return string(abi.encodePacked(converted));
    }

    function uuid4() public returns (string memory){
        return _bytestostring(uuidgen());
    }

    
}
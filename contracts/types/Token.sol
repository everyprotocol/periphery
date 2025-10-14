// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

enum TokenStandard {
    None,
    Native,
    ERC20,
    ERC721,
    ERC1155
}

enum TokenType {
    None,
    Fungible,
    Opaque,
    Object
}

struct TokenSpec {
    TokenStandard std;
    uint8 decimals;
    bytes30 symbol; // left-padded
}

library TokenSpecLib {
    function pack(TokenStandard std, uint8 decimals, bytes30 symbol) internal pure returns (bytes32) {
        return (bytes32(uint256(uint8(std)) << 248)) | (bytes32(uint256(decimals) << 240)) | (bytes32(symbol) >> 16);
    }

    function unpack(bytes32 t) internal pure returns (TokenSpec memory) {
        TokenStandard std = TokenStandard(uint8(uint256(t >> 248)));
        uint8 decimals = uint8(uint256(t >> 240));
        bytes30 symbol = bytes30(t);
        return TokenSpec({std: std, decimals: decimals, symbol: symbol});
    }

    function toBytes30(string memory s) internal pure returns (bytes30 out) {
        bytes memory b = bytes(s);
        if (b.length == 0) return 0x0;
        assembly {
            out := mload(add(b, 32))
        }
    }

    function toString(bytes30 symbol) internal pure returns (string memory) {
        uint256 len = 30;
        while (len > 0 && symbol[len - 1] == 0) {
            len--;
        }
        bytes memory out = new bytes(len);
        for (uint256 i = 0; i < len; ++i) {
            out[i] = symbol[i];
        }
        return string(out);
    }
}

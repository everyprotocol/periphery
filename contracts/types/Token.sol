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
    Value,
    Unique,
    Object
}

struct TokenSpec {
    TokenStandard std; // bits 248–255 (8 bits)
    uint8 decimals; // bits 240–247 (8 bits)
    bytes30 symbol; // bits 0–239 (30 bytes = 240 bits), left-aligned and zero-padded
}

type TokenSpecPacked is bytes32;

using TokenSpecAccessors for TokenSpecPacked global;

library TokenLib {
    function pack(TokenStandard std, uint8 decimals, bytes30 symbol) internal pure returns (bytes32) {
        return (bytes32(uint256(uint8(std)) << 248)) | (bytes32(uint256(decimals) << 240)) | bytes32(symbol);
    }

    function unpack(bytes32 t) internal pure returns (TokenSpec memory) {
        TokenStandard std = TokenStandard(uint8(uint256(t >> 248)));
        uint8 decimals = uint8(uint256(t >> 240));
        bytes30 symbol;
        assembly {
            symbol := t
        }
        return TokenSpec({std: std, decimals: decimals, symbol: symbol});
    }

    function toBytes30(string memory s) internal pure returns (bytes30 out) {
        assembly {
            out := mload(add(s, 32))
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

library TokenSpecAccessors {
    function std(bytes32 t) internal pure returns (uint8) {
        return uint8(uint256(t >> 248));
    }

    function decimals(bytes32 t) internal pure returns (uint8) {
        return uint8(uint256(t >> 240));
    }

    function symbol(bytes32 t) internal pure returns (bytes30) {
        return bytes30(t);
    }

    function std(TokenSpecPacked t) internal pure returns (uint8) {
        return std(TokenSpecPacked.unwrap(t));
    }

    function decimals(TokenSpecPacked t) internal pure returns (uint8) {
        return decimals(TokenSpecPacked.unwrap(t));
    }

    function symbol(TokenSpecPacked t) internal pure returns (bytes30) {
        return symbol(TokenSpecPacked.unwrap(t));
    }
}

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
    Value, // Fungible token
    Unique, // Classic Non-fungible token
    Object // Object token

}

struct TokenSpec {
    TokenStandard std; // Standard (e.g. 1 = ERC20, 2 = ERC721)
    uint8 decimals; // Number of decimals (e.g. 18)
    bytes14 symbol; // Token symbol (e.g. "ETH", "ART")
    uint64 begin; // Start timestamp or block
    uint64 end; // End timestamp or block
}

type TokenSpecPacked is bytes32;

library TokenSpecLib {
    // ─────────────────────────────────────────────────────────────
    // Packing
    // ─────────────────────────────────────────────────────────────

    /// @notice Packs individual TokenSpec fields into bytes32.
    function packTuple(uint8 std_, uint8 decimals_, bytes14 symbol_, uint64 begin_, uint64 end_)
        internal
        pure
        returns (bytes32)
    {
        return bytes32(symbol_) | (bytes32(bytes1(std_)) >> 112) | (bytes32(bytes1(decimals_)) >> 120)
            | (bytes32(bytes8(begin_)) >> 128) | (bytes32(bytes8(end_)) >> 192);
    }

    /// @notice Packs a TokenSpec struct into bytes32.
    function pack(TokenSpec memory s) internal pure returns (bytes32) {
        return packTuple(uint8(s.std), s.decimals, s.symbol, s.begin, s.end);
    }

    // ─────────────────────────────────────────────────────────────
    // Unpacking
    // ─────────────────────────────────────────────────────────────

    /// @notice Unpacks bytes32 into TokenSpec tuple fields.
    function unpack(bytes32 t)
        internal
        pure
        returns (uint8 std_, uint8 decimals_, bytes14 symbol_, uint64 begin_, uint64 end_)
    {
        std_ = std(t);
        decimals_ = decimals(t);
        symbol_ = symbol(t);
        begin_ = begin(t);
        end_ = end(t);
    }

    /// @notice Unpacks bytes32 into a TokenSpec struct.
    function unpackStruct(bytes32 t) internal pure returns (TokenSpec memory) {
        return TokenSpec({
            symbol: symbol(t),
            std: TokenStandard(std(t)),
            decimals: decimals(t),
            begin: begin(t),
            end: end(t)
        });
    }

    /// @notice Unpacks a TokenSpecPack into a TokenSpec struct.
    function unpackStruct(TokenSpecPacked t) internal pure returns (TokenSpec memory) {
        return unpackStruct(TokenSpecPacked.unwrap(t));
    }

    // ─────────────────────────────────────────────────────────────
    // Accessors from bytes32
    // ─────────────────────────────────────────────────────────────

    function symbol(bytes32 t) internal pure returns (bytes14) {
        return bytes14(t);
    }

    function std(bytes32 t) internal pure returns (uint8) {
        return uint8(bytes1(t << 112));
    }

    function decimals(bytes32 t) internal pure returns (uint8) {
        return uint8(bytes1(t << 120));
    }

    function begin(bytes32 t) internal pure returns (uint64) {
        return uint64(bytes8(t << 128));
    }

    function end(bytes32 t) internal pure returns (uint64) {
        return uint64(bytes8(t << 192));
    }

    // ─────────────────────────────────────────────────────────────
    // Accessors from TokenSpecPack
    // ─────────────────────────────────────────────────────────────

    function std(TokenSpecPacked t) internal pure returns (uint8) {
        return std(TokenSpecPacked.unwrap(t));
    }

    function decimals(TokenSpecPacked t) internal pure returns (uint8) {
        return decimals(TokenSpecPacked.unwrap(t));
    }

    function symbol(TokenSpecPacked t) internal pure returns (bytes14) {
        return symbol(TokenSpecPacked.unwrap(t));
    }

    function begin(TokenSpecPacked t) internal pure returns (uint64) {
        return begin(TokenSpecPacked.unwrap(t));
    }

    function end(TokenSpecPacked t) internal pure returns (uint64) {
        return end(TokenSpecPacked.unwrap(t));
    }

    // ─────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────

    /// @notice Converts a string to bytes14 (truncated or zero-padded).
    function toBytes14(string memory symbol_) internal pure returns (bytes14 out) {
        assembly {
            // Load the first 32 bytes of the string (after the length prefix)
            out := mload(add(symbol_, 32))
        }
    }

    /// @notice Converts bytes14 to a string (trimmed to non-zero bytes).
    function toString(bytes14 symbol_) internal pure returns (string memory) {
        uint256 len = 14;
        while (len > 0 && symbol_[len - 1] == 0) {
            len--;
        }
        bytes memory out = new bytes(len);
        for (uint256 i = 0; i < len; ++i) {
            out[i] = symbol_[i];
        }
        return string(out);
    }
}

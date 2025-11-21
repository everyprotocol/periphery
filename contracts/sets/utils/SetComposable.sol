// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library SetComposable {
    /// @custom:storage-location erc7201:every.storage.SetInfo
    struct SetInfoStorage {
        address setRegistry;
        uint64 setId;
        uint32 setRev;
    }

    /// @dev keccak256(abi.encode(uint256(keccak256("every.storage.SetInfo")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SETINFO_STORAGE_LOCATION =
        0xe9d28fb7a22b9ef81c736effd34e13352c20bd969b50ec70879f57b112334b00;

    function getSetInfoStorage() internal pure returns (SetInfoStorage storage $) {
        assembly {
            $.slot := SETINFO_STORAGE_LOCATION
        }
    }

    /// @custom:storage-location erc7201:every.storage.KindInfo
    struct KindInfoStorage {
        address kindRegistry;
        uint64 kindId;
        uint32 kindRev;
    }

    /// @dev keccak256(abi.encode(uint256(keccak256("every.storage.KindInfo")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant KINDINFO_STORAGE_LOCATION =
        0xc26967c9debc855cb6dea0a5c72670e98cba78ef6733e86203f2972442bce600;

    function getKindInfoStorage() internal pure returns (KindInfoStorage storage $) {
        assembly {
            $.slot := KINDINFO_STORAGE_LOCATION
        }
    }

    /// @custom:storage-location erc7201:every.storage.MinterInfo
    struct MinterInfoStorage {
        address objectMinter;
    }

    /// @dev keccak256(abi.encode(uint256(keccak256("every.storage.MinterInfo")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant MINTERINFO_STORAGE_LOCATION =
        0x13ef5fb2f9b4dc4418598121dd5c565e32bb05e9e760f895c1e99cff04b50000;

    function getMinterInfoStorage() internal pure returns (MinterInfoStorage storage $) {
        assembly {
            $.slot := MINTERINFO_STORAGE_LOCATION
        }
    }

    /// @custom:storage-location erc7201:every.storage.OmniInfo
    struct OmniInfoStorage {
        address omniRegistry;
    }

    /// @dev keccak256(abi.encode(uint256(keccak256("every.storage.OmniInfo")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant OMNIINFO_STORAGE_LOCATION =
        0x2c988ff5da05336b8b570436fd61024544ecafb113010fa03290825fd00d9900;

    function getOmniInfoStorage() internal pure returns (OmniInfoStorage storage $) {
        assembly {
            $.slot := OMNIINFO_STORAGE_LOCATION
        }
    }

    function putSetRegistry(address setRegistry) internal {
        SetInfoStorage storage $ = getSetInfoStorage();
        $.setRegistry = setRegistry;
    }

    function putSetId(uint64 setId) internal {
        SetInfoStorage storage $ = getSetInfoStorage();
        $.setId = setId;
    }

    function putSetRev(uint32 setRev) internal {
        SetInfoStorage storage $ = getSetInfoStorage();
        $.setRev = setRev;
    }

    function putSetIdRev(uint64 setId, uint32 setRev) internal {
        SetInfoStorage storage $ = getSetInfoStorage();
        $.setId = setId;
        $.setRev = setRev;
    }

    function putSetInfo(address setRegistry, uint64 setId, uint32 setRev) internal {
        SetInfoStorage storage $ = getSetInfoStorage();
        $.setRegistry = setRegistry;
        $.setId = setId;
        $.setRev = setRev;
    }

    function getSetRegistry() internal view returns (address) {
        SetInfoStorage storage $ = getSetInfoStorage();
        return $.setRegistry;
    }

    function getSetIdRev() internal view returns (uint64, uint32) {
        SetInfoStorage storage $ = getSetInfoStorage();
        return ($.setId, $.setRev);
    }

    function getSetId() internal view returns (uint64) {
        SetInfoStorage storage $ = getSetInfoStorage();
        return $.setId;
    }

    function getSetRev() internal view returns (uint32) {
        SetInfoStorage storage $ = getSetInfoStorage();
        return $.setRev;
    }

    function getSetInfo() internal view returns (address, uint64, uint32) {
        SetInfoStorage storage $ = getSetInfoStorage();
        return ($.setRegistry, $.setId, $.setRev);
    }

    function putObjectMinter(address objectMinter) internal {
        MinterInfoStorage storage $ = getMinterInfoStorage();
        $.objectMinter = objectMinter;
    }

    function getObjectMinter() internal view returns (address) {
        MinterInfoStorage storage $ = getMinterInfoStorage();
        return $.objectMinter;
    }

    function putOmniRegistry(address omniRegistry) internal {
        OmniInfoStorage storage $ = getOmniInfoStorage();
        $.omniRegistry = omniRegistry;
    }

    function getOmniRegistry() internal view returns (address) {
        OmniInfoStorage storage $ = getOmniInfoStorage();
        return $.omniRegistry;
    }

    function putKindRegistry(address kindRegistry) internal {
        KindInfoStorage storage $ = getKindInfoStorage();
        $.kindRegistry = kindRegistry;
    }

    function putKindId(uint64 kindId) internal {
        KindInfoStorage storage $ = getKindInfoStorage();
        $.kindId = kindId;
    }

    function putKindRev(uint32 kindRev) internal {
        KindInfoStorage storage $ = getKindInfoStorage();
        $.kindRev = kindRev;
    }

    function putKindIdRev(uint64 kindId, uint32 kindRev) internal {
        KindInfoStorage storage $ = getKindInfoStorage();
        $.kindId = kindId;
        $.kindRev = kindRev;
    }

    function getKindRegistry() internal view returns (address) {
        KindInfoStorage storage $ = getKindInfoStorage();
        return $.kindRegistry;
    }

    function getKindIdRev() internal view returns (uint64, uint32) {
        KindInfoStorage storage $ = getKindInfoStorage();
        return ($.kindId, $.kindRev);
    }

    function getKindId() internal view returns (uint64) {
        KindInfoStorage storage $ = getKindInfoStorage();
        return $.kindId;
    }

    function getKindRev() internal view returns (uint32) {
        KindInfoStorage storage $ = getKindInfoStorage();
        return $.kindRev;
    }

    function getKindInfo() internal view returns (address, uint64, uint32) {
        KindInfoStorage storage $ = getKindInfoStorage();
        return ($.kindRegistry, $.kindId, $.kindRev);
    }
}

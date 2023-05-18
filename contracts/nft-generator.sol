// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/klaytn/klaytn-contracts/blob/master/contracts/KIP/token/KIP17/KIP17.sol";
import "https://github.com/klaytn/klaytn-contracts/blob/master/contracts/KIP/token/KIP17/extensions/KIP17URIStorage.sol";
import "https://github.com/klaytn/klaytn-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/klaytn/klaytn-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/klaytn/klaytn-contracts/blob/master/contracts/utils/Strings.sol";

contract CarNFT_Generate is KIP17, KIP17URIStorage, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    // 토큰이름: BlockMotors , 토큰심볼: CarNFT
    constructor() KIP17("BlockMotors", "CarNFT") {
    }

    struct CarData {                                    // _CarData[tokenId].data
        string brand;           // 제조사
        string model;           // 모델
        string year;            // 연식
        string licenseNum;      // 차량번호
        string registerNum;     // 등록번호
        string fuel;            // 사용연료
        string cc;              // 배기량
    }

    string private _defaultImageURI = "https://gateway.pinata.cloud/ipfs/QmacnV7iSpZkpvzbR3orPBPpmeX9CCzsURAaxLLZMKWktY";
    string private _8mb_Test = "https://gateway.pinata.cloud/ipfs/QmUQ2kaJx4izSEvXpgdrqNZLYh7h8ESYmMLYCyFzC71RPa";          // 8mb
    string private _1mb_K5 = "https://gateway.pinata.cloud/ipfs/QmTfZBy8TyLnaPWxkRu3PwDELxHVv2Y8JRo5ABYCkUzQDu";            // 1mb
    string private _1mb_Sonata = "https://gateway.pinata.cloud/ipfs/Qmehxw2LFvYsmQf9KtbaUUGoQFzxWyAGhHjNYSoKDFPohR";
    string private _1mb_Tucson = "https://gateway.pinata.cloud/ipfs/QmQPVBH19dxtqHQWq6AuUVAyCygo5DKdFw3R1rcxTsrC3A";
    string private _Danawa_Avante = "https://gateway.pinata.cloud/ipfs/QmYqA1jAdNg5axduHEt34rMHbhX1FdKsJMPvLNMwQPCoXc";     // 50kb
    string private _Danawa_Morning = "https://gateway.pinata.cloud/ipfs/QmVZm7seUnXja8KHpFQk4gXRa6ryJiuHfAzPcb7BQwePwG";
    string private _Danawa_Sonata = "https://gateway.pinata.cloud/ipfs/QmZ27G9ZXnbLPuJoULy3zGWPfZV99iF58UHeVCQXVvpXj1";
    string private _Danawa_Sorento = "https://gateway.pinata.cloud/ipfs/QmVLv5SwahSBL1QK8rYmfBcD68RqGzoiddydkGtgNzr5zx";
    string private _Encar_Avante = "https://gateway.pinata.cloud/ipfs/QmPY7fhHzZhqbyhbS4VxPySgeKVsvyA52saHiYBio2W4BE";      // 400kb
    string private _Encar_Morning = "https://gateway.pinata.cloud/ipfs/QmdmJ1Lt8L7pQL4s6zMh2PyXZhznTUFmJ7zBoCwYKHTSrD";
    string private _Encar_Sonata = "https://gateway.pinata.cloud/ipfs/QmP6CwFpnvmUtALKLVErpu99UxwPqPkv7KyMH9iS5wEBSB";
    string private _Encar_Sorento = "https://gateway.pinata.cloud/ipfs/QmZpDMV6CvhMD3pJu9Dv5LnCDemcj4ZUkVk4mAVrCrDP9w";
    string private _Namu_Avante = "https://gateway.pinata.cloud/ipfs/QmXji4GZVpeSvw4PVqVozSAAVHEngaoDMrq7km4y8tWUL3";       // 500kb
    string private _Namu_Morning = "https://gateway.pinata.cloud/ipfs/QmQ9R99kKhQAJw3GBjNfSWChr4vj6mC25JQsT8Z9qivSkq";
    string private _Namu_Sonata = "https://gateway.pinata.cloud/ipfs/QmRtCToYVb5M6tKPdH1UqwpZ5RhLry9eFWMEPLzFoU2orq";
    string private _Namu_Sorento = "https://gateway.pinata.cloud/ipfs/Qma7tbz97GFxWihRdUrx6wjDQSTpaEUtnha2zE98CiQ6Nj";

    // // 거래컨트랙트 권한 주소
    // address public tradeContractAddress;

    /*
    _CarData: tokenId => CarData                        // _CarData[tokenId]
    _CarsOwned: address => tokenId[]                    // _CarsOwned[address][n]
    */
    mapping(uint256 => CarData) private _CarData;
    mapping(address => uint256[]) private _CarsOwned;

    /*
    setCarData() : 메모리에 CarData 반환
    */
    function setCarData(
        string memory brand,
        string memory model,
        string memory year,
        string memory licenseNum,
        string memory registerNum,
        string memory fuel,
        string memory cc
    ) private pure returns (CarData memory) {
        return CarData({
            brand: brand,
            model: model,
            year: year,
            licenseNum: licenseNum,
            registerNum: registerNum,
            fuel: fuel,
            cc: cc
        });
    }

    /*
    generateCarNFT() : NFT를 발행하고 토큰Id 반환
    */
    function generateCarNFT(
        string memory brand,
        string memory model,
        string memory year,
        string memory licenseNum,
        string memory registerNum,
        string memory fuel,
        string memory cc
    ) public returns (uint256) {
        address to = msg.sender;
        uint256 tokenId = _tokenIdCounter.current();
        _mint(to, tokenId);
        _setTokenURI(tokenId, getTokenImageURI(tokenId));        // 차량모델 => 해당차량이미지
        // _setTokenURI(tokenId, createTokenURI(to, tokenId));
        _tokenIdCounter.increment();

        CarData memory tempCarData = setCarData(
            brand,
            model,
            year,
            licenseNum,
            registerNum,
            fuel,
            cc
        );

        _CarData[tokenId] = tempCarData;
        _CarsOwned[to].push(tokenId);
        
        return tokenId;
    }

    /*
    updateCarNFT() : 토큰Id의 CarData 수정
    */
    function updateCarNFT(
        uint256 tokenId,
        string memory brand,
        string memory model,
        string memory year,
        string memory licenseNum,
        string memory registerNum,
        string memory fuel,
        string memory cc
    ) public {
        require(_exists(tokenId), "Token ID does not exist");
        require(msg.sender == ownerOf(tokenId), "Only NFT owner can call this function");
        _setTokenURI(tokenId, getTokenImageURI(tokenId));        // 차량모델 => 해당차량이미지

        CarData memory tempCarData = setCarData(
            brand,
            model,
            year,
            licenseNum,
            registerNum,
            fuel,
            cc
        );

        _CarData[tokenId] = tempCarData;
    }

    /*
    getCarNFT() : 토큰Id의 CarData 반환
    */
    function getCarNFT(uint256 tokenId) public view returns (
        string memory,
        string memory,
        string memory,
        string memory,
        string memory,
        string memory,
        string memory
    ) {
        require(_exists(tokenId), "Token ID does not exist");
        CarData memory tempCarData = _CarData[tokenId];

        return(
            tempCarData.brand,
            tempCarData.model,
            tempCarData.year,
            tempCarData.licenseNum,
            tempCarData.registerNum,
            tempCarData.fuel,
            tempCarData.cc
        );
    }

    /*
    getOwnedTokenIds() : 사용자가 소유한 토큰Id목록 반환
    */
    function getOwnedTokenIds(address user) public view returns (uint256[] memory) {
        require(user != address(0), "User Address does not exist");
        if (_CarsOwned[user].length == 0) {
            uint256[] memory emptyArray;
            return emptyArray;
        } else {
            return _CarsOwned[user];
        }
    }

    /*
    getEveryTokenIds() : 발행된 전체 토큰Id목록 반환
    */
    function getEveryTokenIds() public view returns (uint256[] memory) {
        uint256[] memory tempTokenIds = new uint256[](_tokenIdCounter.current());
        uint256 index = 0;
        for (uint256 i = 0; i < _tokenIdCounter.current(); i++) {
           uint256 tokenId = i;
            if (_exists(tokenId)) {
                tempTokenIds[index] = tokenId;
                index++;
            }
        }
        require(index > 0, "There are no tokens");
        uint256[] memory EveryTokenIds = new uint256[](index);
        for (uint256 i = 0; i < index; i++) {
            EveryTokenIds[i] = tempTokenIds[i];
        }
        return EveryTokenIds;
    }

    /*
    deleteCarNFT() : 토큰Id의 CarData 삭제
    */
    function deleteCarNFT(uint256 tokenId) public {
        require(_exists(tokenId), "Token ID does not exist");
        require(msg.sender == ownerOf(tokenId), "Only NFT owner can call this function");
        delete _CarData[tokenId];
        removeTokenIdFrom(ownerOf(tokenId), tokenId);
        _transfer(ownerOf(tokenId), address(0), tokenId);
    }

    /*
    remapTokenId() : 거래완료 후 사용자가 소유한 토큰Id목록 변경
    */
    function remapTokenId(address from, address to, uint256 tokenId) internal {
        removeTokenIdFrom(from, tokenId);
        addTokenIdTo(to, tokenId);
    }

    /*
    addTokenIdTo() : 사용자가 소유한 토큰Id목록에 거래완료된 토큰Id를 추가
    */
    function addTokenIdTo(address owner, uint256 tokenId) internal {
        _CarsOwned[owner].push(tokenId);
    }

    /*
    removeTokenIdFrom() : 사용자가 소유한 토큰Id목록에 거래완료된 토큰Id를 삭제
    */
    function removeTokenIdFrom(address owner, uint256 tokenId) internal {
        uint256[] storage tempTokenIds = _CarsOwned[owner];
        for (uint256 i=0; i < _CarsOwned[owner].length; i++){
            if (tempTokenIds[i] == tokenId){
                if (i < tempTokenIds.length - 1) {
                tempTokenIds[i] = tempTokenIds[tempTokenIds.length - 1];
                }
                tempTokenIds.pop();
                break;
            }
        }
    }

    // /*
    // setTradeContractAddress() : 거래컨트랙트 권한 주소 설정
    // */
    // function setTradeContractAddress(address tradeContract) public onlyOwner {
    //     tradeContractAddress = tradeContract;
    // }

    // /*
    // getTokenImageURI() : 토큰 URI 생성 - 차량모델 => 해당차량이미지
    // */
    function getTokenImageURI(uint256 tokenId) private view returns (string memory) {
        string memory model = _CarData[tokenId].model;
        if (bytes(model).length > 0) {
            return getModelImageURI(model);
        }
        return _defaultImageURI;
    }

    function getModelImageURI(string memory model) private view returns (string memory) {
    string memory lowercaseModel = toLowerCase(model);
        if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("8mb_test"))) {
            return _8mb_Test;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("1mb_k5"))) {
            return _1mb_K5;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("1mb_sonata"))) {
            return _1mb_Sonata;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("1mb_tucson"))) {
            return _1mb_Tucson;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("danawa_avante"))) {
            return _Danawa_Avante;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("danawa_morning"))) {
            return _Danawa_Morning;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("danawa_sonata"))) {
            return _Danawa_Sonata;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("danawa_sorento"))) {
            return _Danawa_Sorento;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("encar_avante"))) {
            return _Encar_Avante;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("encar_morning"))) {
            return _Encar_Morning;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("encar_sonata"))) {
            return _Encar_Sonata;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("encar_sorento"))) {
            return _Encar_Sorento;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("namu_avante"))) {
            return _Namu_Avante;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("namu_morning"))) {
            return _Namu_Morning;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("namu_sonata"))) {
            return _Namu_Sonata;
        } else if (keccak256(bytes(lowercaseModel)) == keccak256(bytes("namu_sorento"))) {
            return _Namu_Sorento;
        } else {
            return _defaultImageURI;
        }
    }

    function toLowerCase(string memory str) private pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        for (uint i = 0; i < strBytes.length; i++) {
            if ((uint8(strBytes[i]) >= 65) && (uint8(strBytes[i]) <= 90)) {
                strBytes[i] = bytes1(uint8(strBytes[i]) + 32);
            }
        }
        return string(strBytes);
    }

    // /*
    // createTokenURI() : 토큰 URI 생성
    // */
    // function createTokenURI(address to, uint256 tokenId) private view returns (string memory) {
    //     require(_exists(tokenId), "Token ID does not exist");
    //     return string(abi.encodePacked(to, Strings.toString(tokenId)));
    // }

    /*
    tokenURI() : 토큰Id의 URI 반환 (KIP17URIStorage/Override)
    */
    function tokenURI(uint256 tokenId) public view virtual override(KIP17, KIP17URIStorage) returns (string memory) {
        require(_exists(tokenId), "Token ID does not exist");
        return KIP17URIStorage.tokenURI(tokenId);
    }

    /*
    _burn() : 토큰 소멸시 특정 로직을 추가함 (KIP17URIStorage/Override)
    */
    function _burn(uint256 tokenId) internal virtual override(KIP17, KIP17URIStorage) {
        KIP17URIStorage._burn(tokenId);
    }
}
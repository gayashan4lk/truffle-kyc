// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Identity {
    uint32 public userId = 0; // how to user random Ids (like guid) in solidity?
    uint32 public credentialsId = 0;
    uint32 public revealRecordId = 0;
    uint32 public signRecordId = 0;

    enum UserType {
        Owner,
        Issuer,
        Verifier
    }

    struct User {
        address userAddress;
        string userName;
        string passWord;
        UserType userType;
    }

    mapping(uint32 => User) public Users;

    struct Credentials {
        uint32 credentialsId;
        address ownerAddress;
        address issuerAddress;
        string credentialsName;
        string credentialsDetails; // external API could be linked here.
        uint32 createdAt;
    }

    mapping(address => mapping(uint32 => Credentials)) public CredentialsList;

    struct RevealRecord {
        address ownerAddress;
        address verifierAddress;
        uint32 credentialsId;
        bool isRevealed;
        uint32 createdAt;
    }

    mapping(address => mapping(uint32 => RevealRecord)) public RevealRecordBook;

    struct SignRecord {
        address ownerAddress;
        address IssuerAddress;
        uint32 credentialsId;
        bool isSigned;
        uint32 createdAt;
    }

    mapping(address => mapping(uint32 => SignRecord)) public SignRecordBook;

    function addUser(
        address _address,
        string memory _name,
        string memory _pass,
        string memory _type
    ) public returns (uint32) {
        if (
            keccak256(abi.encodePacked(_type)) == keccak256("Issuer") ||
            keccak256(abi.encodePacked(_type)) == keccak256("Owner") ||
            keccak256(abi.encodePacked(_type)) == keccak256("Verifier")
        ) {
            UserType _userType;
            if (keccak256(abi.encodePacked(_type)) == keccak256("Issuer")) {
                _userType = UserType.Issuer;
            } else if (
                keccak256(abi.encodePacked(_type)) == keccak256("Owner")
            ) {
                _userType = UserType.Owner;
            } else if (
                keccak256(abi.encodePacked(_type)) == keccak256("Verifier")
            ) {
                _userType = UserType.Verifier;
            }
            uint32 _id = userId++;
            Users[_id] = User(_address, _name, _pass, _userType);
            return _id;
        }
        return 0;
    }

    function getUser(uint32 _id) public view returns (User memory) {
        return (Users[_id]);
    }

    function addCredentials(
        uint32 _userId,
        address _owner,
        address _issuer,
        string memory _name,
        string memory _details
    ) public returns (uint32) {
        if (Users[_userId].userType == UserType.Owner) {
            uint32 _credentialsId = credentialsId++;
            CredentialsList[_owner][_credentialsId] = Credentials(
                _credentialsId,
                _owner,
                _issuer,
                _name,
                _details,
                uint32(block.timestamp)
            );
            return _credentialsId;
        }
        return 0;
    }

    function getCredentialsByOwner(address _address, uint32 _id)
        public
        view
        returns (Credentials memory)
    {
        return (CredentialsList[_address][_id]);
    }

    function revealCredentials(
        uint32 _ownerId,
        uint32 _verifierId,
        uint32 _credentialsId
    ) public returns (uint32) {
        if (Users[_ownerId].userType == UserType.Owner) {
            uint32 _id = revealRecordId++;
            RevealRecordBook[Users[_ownerId].userAddress][_id] = RevealRecord(
                Users[_ownerId].userAddress,
                Users[_verifierId].userAddress,
                _credentialsId,
                true,
                uint32(block.timestamp)
            );
            return (_id);
        }
        return 0;
    }

    function requestCredentials(
        uint32 _verifierId,
        uint32 _ownerId,
        uint32 _credentialsId
    ) public returns (uint32) {
        if (Users[_verifierId].userType == UserType.Verifier) {
            uint32 _id = revealRecordId++;
            RevealRecordBook[Users[_ownerId].userAddress][_id] = RevealRecord(
                Users[_ownerId].userAddress,
                Users[_verifierId].userAddress,
                _credentialsId,
                false,
                uint32(block.timestamp)
            );
            return (_id);
        }
        return 0;
    }

    function getRevealRecord(address _ownerAddress, uint32 _id)
        public
        view
        returns (RevealRecord memory)
    {
        return (RevealRecordBook[_ownerAddress][_id]);
    }

    function signCredentials(
        uint32 _ownerId,
        uint32 _issuerId,
        uint32 _credentialsId
    ) public returns (uint32) {
        if (Users[_issuerId].userType == UserType.Issuer) {
            uint32 _id = signRecordId++;
            SignRecordBook[Users[_ownerId].userAddress][_id] = SignRecord(
                Users[_ownerId].userAddress,
                Users[_issuerId].userAddress,
                _credentialsId,
                true,
                uint32(block.timestamp)
            );
            return (_id);
        }
        return 0;
    }

    function unSignCredentials(
        uint32 _ownerId,
        uint32 _issuerId,
        uint32 _credentialsId
    ) public returns (uint32) {
        if (Users[_issuerId].userType == UserType.Issuer) {
            uint32 _id = signRecordId++;
            SignRecordBook[Users[_ownerId].userAddress][_id] = SignRecord(
                Users[_ownerId].userAddress,
                Users[_issuerId].userAddress,
                _credentialsId,
                false,
                uint32(block.timestamp)
            );
            return (_id);
        }
        return 0;
    }

    function getSignRecord(address _ownerAddress, uint32 _id)
        public
        view
        returns (SignRecord memory)
    {
        return (SignRecordBook[_ownerAddress][_id]);
    }
}

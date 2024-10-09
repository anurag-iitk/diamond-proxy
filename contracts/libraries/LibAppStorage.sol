// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct Proposal {
    uint256 proposalId;
    address payable recipient;
    uint256 amount;
    uint256 approvals;
    bool executed;
    mapping(address => bool) approversVoted;
}

struct AppStorage {
    uint256 threshold;
    uint256 approversCount;
    uint256 proposalCount;
    mapping(address => bool) approversMap;
    mapping(uint256 => Proposal) proposalsMap;
}

library LibAppStorage {
    function getAppStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}
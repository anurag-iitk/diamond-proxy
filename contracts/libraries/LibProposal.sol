// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Proposal, AppStorage, LibAppStorage} from "./LibAppStorage.sol";

library LibProposal {
    event ProposalApproved(uint256 indexed proposalId);
    event ProposalExecuted(uint256 indexed _proposalId);

    function depositETH() internal {
        require(msg.value > 0 ether, "Must send some ETH");
    }

    function createProposal(address payable _recipient, uint256 _amount) internal {
        require(_recipient != address(0), "Recipient must not be null");
        require(_amount > 0, "Amount must greater than zero");
        require(address(this).balance >= _amount, "Insufficient funds in contract");
        AppStorage storage ds = LibAppStorage.getAppStorage();
        ds.proposalCount++;
        ds.proposalsMap[ds.proposalCount].proposalId = ds.proposalCount;
        ds.proposalsMap[ds.proposalCount].recipient = _recipient;
        ds.proposalsMap[ds.proposalCount].amount = _amount;
        ds.proposalsMap[ds.proposalCount].approvals = 0;
        ds.proposalsMap[ds.proposalCount].executed = false;
    }

    function approveProposal(uint256 _proposalId) external {
        require(_proposalId != 0, "ProposalId must not equal to zero");
        AppStorage storage ds = LibAppStorage.getAppStorage();
        require(ds.proposalsMap[_proposalId].proposalId != 0, "Proposal does not exist");
        require(ds.proposalsMap[_proposalId].executed, "Proposal already executed");
        require(!ds.proposalsMap[_proposalId].approversVoted[msg.sender], "You already voted for this proposal");
        ds.proposalsMap[_proposalId].approversVoted[msg.sender] = true;
        ds.proposalsMap[_proposalId].approvals++;
        emit ProposalApproved(_proposalId);
        if (ds.proposalsMap[_proposalId].approvals >= ds.threshold) {
            executeProposal(_proposalId);
        }
    }

    function executeProposal(uint256 _proposalId) internal {
        AppStorage storage ds = LibAppStorage.getAppStorage();
        require(ds.proposalsMap[_proposalId].approvals >= ds.threshold, "Not enough approvals");
        require(!ds.proposalsMap[_proposalId].executed, "Proposal already executed");
        ds.proposalsMap[_proposalId].executed = true;
        (ds.proposalsMap[_proposalId].recipient).transfer(ds.proposalsMap[_proposalId].amount);
        emit ProposalExecuted(_proposalId);
    }
}

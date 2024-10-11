// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {LibApprover} from "../libraries/LibApprover.sol";
import {IProposalFacet} from "../interfaces/IProposal.sol";
import {Proposal, AppStorage, LibAppStorage} from "../libraries/LibAppStorage.sol";

contract ProposalFacet is IProposalFacet {
    modifier onlyApprover() {
        require(LibApprover.getApprover(msg.sender), "Caller is not an approver");
        _;
    }

    function depositEther() external payable override {
        require(msg.value > 0 ether, "Must send some ETH");
    }

    function createProposal(address payable _recipient, uint256 _amount) external onlyApprover override {
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
        emit ProposalAdded(_recipient, _amount);
    }

    function approveProposal(uint256 _proposalId) external onlyApprover override {
        require(_proposalId != 0, "ProposalId must not equal to zero");
        AppStorage storage ds = LibAppStorage.getAppStorage();
        require(ds.proposalsMap[_proposalId].proposalId != 0, "Proposal does not exist");
        require(!ds.proposalsMap[_proposalId].executed, "Proposal already executed");
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
        (bool success, ) = ds.proposalsMap[_proposalId].recipient.call{value: ds.proposalsMap[_proposalId].amount}("");
        require(success, "Transfer failed");
        emit ProposalExecuted(_proposalId);
    }

    function getProposal(uint256 _proposalId)
        external
        override
        view
        returns (
            uint256 proposalId,
            address recipient,
            uint256 amount,
            uint256 approvals,
            bool executed
        )
    {
        AppStorage storage ds = LibAppStorage.getAppStorage();
        require(ds.proposalsMap[_proposalId].proposalId != 0, "Proposal does not exist");

        return (
            ds.proposalsMap[_proposalId].proposalId,
            ds.proposalsMap[_proposalId].recipient,
            ds.proposalsMap[_proposalId].amount,
            ds.proposalsMap[_proposalId].approvals,
            ds.proposalsMap[_proposalId].executed
        );
    }
}

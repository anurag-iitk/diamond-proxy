// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { LibProposal } from "../libraries/LibProposal.sol";
import { LibApprover } from "../libraries/LibApprover.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";

contract ProposalFacet {

    event ProposalAdded(address indexed recipient, uint256 amount);

    modifier onlyApprover() {
        require(LibApprover.getApprover(msg.sender), "Caller is not an approver");
        _;
    }

    function createProposal(address payable _recipient, uint256 _amount) external {
        LibProposal.createProposal(_recipient, _amount);
        emit ProposalAdded(_recipient, _amount);
    }

    function approveProposal(uint256 _proposalId) external {
        LibProposal.approveProposal(_proposalId);
    }
}
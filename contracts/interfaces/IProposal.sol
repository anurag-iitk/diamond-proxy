// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IProposalFacet {
    event ProposalAdded(address indexed recipient, uint256 amount);
    event ProposalApproved(uint256 indexed proposalId);
    event ProposalExecuted(uint256 indexed _proposalId);

    function depositEther() external payable;

    function createProposal(address payable _recipient, uint256 _amount) external;

    function approveProposal(uint256 _proposalId) external;

    function getProposal(
        uint256 _proposalId
    ) external view returns (uint256 proposalId, address recipient, uint256 amount, uint256 approvals, bool executed);
}

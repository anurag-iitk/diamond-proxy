// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IApprover {
    event ApproverAdded(address indexed approver);
    event ApproverDeleted(address indexed approver);

    function addApprover(address _approver) external;
    function deleteApprover(address _approver) external;
    function getApprover(address _approver) external view returns (bool);
}

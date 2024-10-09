// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibApprover } from "../libraries/LibApprover.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";

contract ApprovalFacet {

    event ApproverAdded(address indexed approver);
    event ApproverDeleted(address indexed approver);
    
    function addApprover(address _approver) external {
        LibDiamond.enforceIsContractOwner();
        LibApprover.addApprover(_approver);
        emit ApproverAdded(_approver);
    }

    function deleteApprover(address _approver) external {
        LibDiamond.enforceIsContractOwner();
        LibApprover.deleteApprover(_approver);
        emit ApproverDeleted(_approver);
    }

    function getApprover(address _approver) external view {
        LibApprover.getApprover(_approver);
    }
}
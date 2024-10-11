// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibApprover } from "../libraries/LibApprover.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";
import {IApprover} from "../interfaces/IApprover.sol";
import {AppStorage, LibAppStorage} from "../libraries/LibAppStorage.sol";

contract ApprovalFacet is IApprover{

    function addApprover(address _approver) external override {
        LibDiamond.enforceIsContractOwner();
        require(_approver != address(0), "Address must not equal to zero");
        AppStorage storage ds = LibAppStorage.getAppStorage();
        require(!ds.approversMap[_approver], "Approver already exist");
        ds.approversMap[_approver] = true;
        ds.approversCount++;
        emit ApproverAdded(_approver);
    }

    function deleteApprover(address _approver) external override {
        LibDiamond.enforceIsContractOwner();
        require(_approver != address(0), "Address must not equal to zero");
        AppStorage storage ds = LibAppStorage.getAppStorage();
        require(ds.approversMap[_approver], "Approver does not exist");
        delete (ds.approversMap[_approver]);
        ds.approversCount--;
        emit ApproverDeleted(_approver);
    }

    function getApprover(address _approver) external override view returns (bool) {
        return LibApprover.getApprover(_approver);
    }
}
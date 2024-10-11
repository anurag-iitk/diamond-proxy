// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AppStorage, LibAppStorage} from "./LibAppStorage.sol";

library LibApprover {
    function getApprover(address _approver) internal view returns (bool) {
        require(_approver != address(0), "Address must not equal to zero");
        AppStorage storage ds = LibAppStorage.getAppStorage();
        require(ds.approversMap[_approver], "Approver does not exist");
        return ds.approversMap[_approver];
    }
}

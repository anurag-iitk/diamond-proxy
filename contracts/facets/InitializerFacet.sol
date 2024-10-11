// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../helpers/Initializable.sol";
import {AppStorage, LibAppStorage} from "../libraries/LibAppStorage.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IInitializer} from "../interfaces/IInitializer.sol";

contract InitializerFacet is IInitializer, Initializable{

    function initialize(uint256 _threshold) external override initializer {
        LibDiamond.enforceIsContractOwner();
        AppStorage storage ds = LibAppStorage.getAppStorage();
        ds.threshold = _threshold;
        emit ThresholdSet(_threshold);
    }
}

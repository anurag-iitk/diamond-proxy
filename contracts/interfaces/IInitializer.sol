// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IInitializer {
    event ThresholdSet(uint256 threshold);

    function initialize(uint256 _threshold) external;
}

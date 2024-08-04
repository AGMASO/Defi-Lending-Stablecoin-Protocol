// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/interfaces/AggregatorV3Interface.sol";

library OracleLib {
    error OracleLib__ChainlinkPriceFeedNotWorking();
    uint256 private constant TIMEOUT = 3 hours;
    function checkIfOnLatestRoundData(
        AggregatorV3Interface priceFeed
    ) public view returns (uint80, int256, uint256, uint256, uint80) {
        (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        if (block.timestamp - updatedAt > TIMEOUT) {
            revert OracleLib__ChainlinkPriceFeedNotWorking();
        }
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}

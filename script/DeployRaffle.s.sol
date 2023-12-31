// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interaction.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            address vrfCoordinator,
            address link,
            bytes32 gasLane,
            uint256 deployerKey,
            uint256 interval,
            uint256 entranceFee,
            uint64 subscriptionId,
            uint32 callbackGasLimit
        ) = helperConfig.activeNetworkConfig();

        if (subscriptionId == 0) {
            // Create new  subscription
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(vrfCoordinator, deployerKey);

            // Fund it!
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(vrfCoordinator, link, deployerKey, subscriptionId);
        }

        vm.startBroadcast(deployerKey);
        Raffle raffle = new Raffle(vrfCoordinator, gasLane, interval, entranceFee, subscriptionId, callbackGasLimit);
        vm.stopBroadcast();

        //  Add consumer
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(vrfCoordinator, address(raffle), deployerKey, subscriptionId);

        return (raffle, helperConfig);
    }
}

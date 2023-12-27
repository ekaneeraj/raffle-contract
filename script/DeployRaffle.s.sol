// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import { CreateSubscription } from "./Interaction.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            address vrfCoordinator,
            , 
            bytes32 gasLane,
            uint256 interval,
            uint256 entranceFee,
            uint64 subscriptionId,
            uint32 callbackGasLimit
        ) = helperConfig.activeNetworkConfig();

        if (subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(vrfCoordinator);
            
        }
        
        vm.startBroadcast();
        Raffle raffle = new Raffle(vrfCoordinator, gasLane, interval, entranceFee, subscriptionId, callbackGasLimit);
        vm.stopBroadcast();

        return (raffle, helperConfig);
    }
}
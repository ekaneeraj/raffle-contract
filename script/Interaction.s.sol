// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Script, console } from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import { LinkToken } from "../test/mock/LinkToken.sol";

contract CreateSubscription is Script {
    function createSubscription(address _vrfCoordinator) public returns (uint64) {
        console.log("Creating subscription on chain id: ", block.chainid);
        
        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(_vrfCoordinator).createSubscription();
        vm.stopBroadcast();

        console.log("Your sub id is : ", subId);
        console.log("Please update subscriptionId in HelperConfig.s.sol");
        return subId;
    }

    function createSubscriptionUsingConfig() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (address vrfCoordinator, address link,,,,,) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinator);
    }

    function run() external returns (uint64) {
        return createSubscriptionUsingConfig();
    }
}


contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscription(address _vrfCoordinator, address _link, uint64 _subscriptionId) public {
        console.log("Funding subscription: ", _subscriptionId);
        console.log("Using vrfCoordinator: ", _vrfCoordinator);
        console.log("On chain ID: ", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(_vrfCoordinator).fundSubscription(_subscriptionId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(_link).transferAndCall(_vrfCoordinator, FUND_AMOUNT, abi.encode(_subscriptionId));
            vm.stopBroadcast();
        }
    }

    function fundSubscriptionUsingConfig() public  {
        HelperConfig helperConfig = new HelperConfig();
        (address vrfCoordinator, address link,,,,uint64 subscriptionId,) = helperConfig.activeNetworkConfig();
        fundSubscription(vrfCoordinator, link, subscriptionId);
    }

        function run() external {
        return fundSubscriptionUsingConfig();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {DevOpsTools} from "@chainlink/devops/DevOpsTools.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {LinkToken} from "../test/mock/LinkToken.sol";

contract CreateSubscription is Script {
    function createSubscription(address _vrfCoordinator, uint256 _deployerKey) public returns (uint64) {
        console.log("Creating subscription on chain id: ", block.chainid);

        vm.startBroadcast(_deployerKey);
        uint64 subId = VRFCoordinatorV2Mock(_vrfCoordinator).createSubscription();
        vm.stopBroadcast();

        console.log("Your sub id is : ", subId);
        console.log("Please update subscriptionId in HelperConfig.s.sol");
        return subId;
    }

    function createSubscriptionUsingConfig() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (address vrfCoordinator,,,uint256 deployerKey,,,,) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinator, deployerKey);
    }

    function run() external returns (uint64) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscription(address _vrfCoordinator, address _link, uint256 _deployerKey, uint64 _subscriptionId) public {
        console.log("Funding subscription: ", _subscriptionId);
        console.log("Using vrfCoordinator: ", _vrfCoordinator);
        console.log("On chain ID: ", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast(_deployerKey);
            VRFCoordinatorV2Mock(_vrfCoordinator).fundSubscription(_subscriptionId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(_link).transferAndCall(_vrfCoordinator, FUND_AMOUNT, abi.encode(_subscriptionId));
            vm.stopBroadcast();
        }
    }

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (address vrfCoordinator, address link, ,uint256 deployerKey,,, uint64 subscriptionId,) = helperConfig.activeNetworkConfig();
        fundSubscription(vrfCoordinator, link, deployerKey, subscriptionId);
    }

    function run() external {
        return fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumer(address _vrfCoordinator, address _raffleAddress, uint256 _deployerKey, uint64 _subscriptionId) public {
        console.log("Adding consumer contract: ", _raffleAddress);
        console.log("Using vrfCoordinator: ", _vrfCoordinator);
        console.log("On chain ID: ", block.chainid);

        vm.startBroadcast(_deployerKey);
        VRFCoordinatorV2Mock(_vrfCoordinator).addConsumer(_subscriptionId, _raffleAddress);
        vm.stopBroadcast();
    }

    function addConsumerUsingConfig(address _mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        (address vrfCoordinator,,,uint256 deployerKey,,, uint64 subscriptionId,) = helperConfig.activeNetworkConfig();

        addConsumer(vrfCoordinator, _mostRecentlyDeployed, deployerKey, subscriptionId);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}

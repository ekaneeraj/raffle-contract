// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mock/LinkToken.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    address vrfCoordinatorAddressSepolia = vm.envAddress("SEPOLIA_VRF_COORDINATOR");
    address linkAddressSepolia = vm.envAddress("SEPOLIA_LINK_ADDRESS");
    bytes32 gasLaneHashSepolia = vm.envBytes32("SEPOLIA_GAS_LANE");
    uint64 subId = uint64(vm.envUint("SUBSCRIPTION_ID"));

    uint256 public INTERVAL = 30;
    uint256 public ENTRANCE_FEE = 0.01 ether;
    uint64 public SUBSCRIPTION_ID = 0;
    uint32 public CALLBACK_GAS_LIMIT = 500000;

    struct NetworkConfig {
        address vrfCoordinator;
        address link;
        bytes32 gasLane;
        uint256 deployerKey;
        uint256 interval;
        uint256 entranceFee;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            vrfCoordinator: vrfCoordinatorAddressSepolia,
            link: linkAddressSepolia,
            gasLane: gasLaneHashSepolia,
            deployerKey: vm.envUint("PRIVATE_KEY"),
            interval: INTERVAL,
            entranceFee: ENTRANCE_FEE,
            subscriptionId: subId,
            callbackGasLimit: CALLBACK_GAS_LIMIT
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        uint96 baseFee = 0.25 ether; // 0.25 LINK
        uint96 gasPriceLink = 1e9; // 1gwei LINK

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorV2Mock = new VRFCoordinatorV2Mock(baseFee, gasPriceLink);
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();

        return NetworkConfig({
            vrfCoordinator: address(vrfCoordinatorV2Mock),
            link: address(linkToken),
            gasLane: gasLaneHashSepolia,
            deployerKey: vm.envUint("ANVIL_KEY"),
            interval: INTERVAL,
            entranceFee: ENTRANCE_FEE,
            subscriptionId: SUBSCRIPTION_ID,
            callbackGasLimit: CALLBACK_GAS_LIMIT
        });
    }
}

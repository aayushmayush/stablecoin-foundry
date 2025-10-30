//SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "../mocks/MockERC20.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DSCEngineErrors} from "../../src/interfaces/DSCEngineErrors.sol";

contract MyTestDSCEngine is Test, DSCEngineErrors {
    DeployDSC deployer;
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    address weth;
    address wbtc;
    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    address[] public tokenAddresses;
    address[] public feedAddresses;
    HelperConfig config;

    address user = makeAddr("user");
    address aayush = makeAddr("aayush");

    function setUp() public {
        deployer = new DeployDSC();

        (dsc, dsce, config) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc, ) = config
            .activeNetworkConfig();

        ERC20Mock(weth).mint(aayush, 1000 ether);
        ERC20Mock(wbtc).mint(aayush, 100 ether);
    }

    function testInitialVariables() public {
        assertEq(dsce.getDsc(), address(dsc));
        assertEq(dsce.getCollateralTokenPriceFeed(weth), ethUsdPriceFeed);
        assertEq(dsce.getCollateralTokenPriceFeed(wbtc), btcUsdPriceFeed);

        tokenAddresses.push(weth);
        tokenAddresses.push(wbtc);

        assertEq(dsce.getCollateralTokens(), tokenAddresses);
    }

    function testConstructorRevertsForEmptyTokenAddreses() public {
        feedAddresses.push(ethUsdPriceFeed);
        feedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(
            DSCEngine__TokenAddressesAndPriceFeedAddressesLengthMustBeNonZero
                .selector
        );

        new DSCEngine(tokenAddresses, feedAddresses, address(dsc));
    }

    function testConstructorRevertsForEmptyFeedAddreses() public {
        tokenAddresses.push(weth);
        tokenAddresses.push(wbtc);

        vm.expectRevert(
            DSCEngine__TokenAddressesAndPriceFeedAddressesLengthMustBeNonZero
                .selector
        );

        new DSCEngine(tokenAddresses, feedAddresses, address(dsc));
    }

    function testConstructorRevertsForWalletAddressFordsc() public {
        tokenAddresses.push(weth);
        tokenAddresses.push(wbtc);
        feedAddresses.push(ethUsdPriceFeed);
        feedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(DSCEngine__ShouldBeAContract.selector);

        new DSCEngine(tokenAddresses, feedAddresses, user);
    }

    function testConstructorRevertsForZeroWalletAddressFordsc() public {
        tokenAddresses.push(weth);
        tokenAddresses.push(wbtc);
        feedAddresses.push(ethUsdPriceFeed);
        feedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(DSCEngine__DscAddressShouldBeNonZero.selector);

        new DSCEngine(tokenAddresses, feedAddresses, address(0));
    }

    function testConstructorRevertsForZeroTokenAddress() public {
        tokenAddresses.push(weth);
        tokenAddresses.push(address(0));
        feedAddresses.push(ethUsdPriceFeed);
        feedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(
            DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeNonZero.selector
        );

        new DSCEngine(tokenAddresses, feedAddresses, address(dsc));
    }

    function testConstructorRevertsForZeroFeedAddress() public {
        tokenAddresses.push(weth);
        tokenAddresses.push(wbtc);
        feedAddresses.push(address(0));
        feedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(
            DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeNonZero.selector
        );

        new DSCEngine(tokenAddresses, feedAddresses, address(dsc));
    }

    function testDepositCollateralAndMintDsc() public {
        uint256 singleCollateralValueMaxDsc = dsce.getUSDValue(weth, 1 ether)/2;
        console.log("amount of dsc to mint ", singleCollateralValueMaxDsc);

        vm.startPrank(aayush);
        ERC20Mock(weth).approve(address(dsce), 1000 ether);
        // vm.expectRevert();
        dsce.depositCollateralAndMintDsc(
            weth,
            1 ether,
            singleCollateralValueMaxDsc
        );
        vm.stopPrank();

        console.log("Here is the balance", dsc.balanceOf(aayush));
    }
}
// 1e21 is dsc to mint
//amount is 2e21 after adjustment its 1e21
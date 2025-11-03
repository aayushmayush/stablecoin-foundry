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
        assertEq(dsce.getCollateralBalanceOfUser(address(deployer), weth), 0);
        assertEq(dsce.getCollateralBalanceOfUser(address(deployer), wbtc), 0);
        assertEq(dsce.getDSCMinted(address(deployer)), 0);
        assertEq(dsce.getPrecision(), 1e18);
        assertEq(dsce.getLiquidationThreshold(), 50);
        assertEq(dsce.getLiquidationPrecision(), 100);
        assertEq(dsce.getLiquidationBonus(), 10);
        assertEq(dsce.getMinHealthFactor(), 1e18);
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

    function testConstructorRevertsForUnequalTokenAndFeedAddresses() public {
        tokenAddresses.push(weth);
        tokenAddresses.push(wbtc);
        tokenAddresses.push(address(dsc));
        feedAddresses.push(ethUsdPriceFeed);
        feedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(
            DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength
                .selector
        );

        new DSCEngine(tokenAddresses, feedAddresses, address(dsc));
    }

    function testConstructorRevertsForZeroDSCAddressFordsc() public {
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
        uint256 singleCollateralValueInDsc = dsce.getUSDValue(weth, 1 ether) /
            2;
        console.log("amount of dsc to mint ", singleCollateralValueInDsc);

        vm.startPrank(aayush);
        ERC20Mock(weth).approve(address(dsce), 2 ether);
        // vm.expectRevert();
        dsce.depositCollateralAndMintDsc(
            weth,
            1 ether,
            singleCollateralValueInDsc
        );
        vm.stopPrank();

        console.log("Here is the balance", dsc.balanceOf(aayush));
    }

    function testDepositCollateralAndMintDscJustOneWeiMore() public {
        uint256 singleCollateralValueInDsc = dsce.getUSDValue(weth, 1 ether) /
            2;
        console.log("amount of dsc to mint ", singleCollateralValueInDsc);

        vm.startPrank(aayush);
        ERC20Mock(weth).approve(address(dsce), 1000 ether);
        vm.expectRevert();
        dsce.depositCollateralAndMintDsc(
            weth,
            1 ether,
            singleCollateralValueInDsc + 1 //just with one wei more health factor will be broken
        );
        vm.stopPrank();

        console.log("Here is the balance", dsc.balanceOf(aayush));
    }

    function testDepositCollateralAndMintMoreDscThanDeserved() public {
        uint256 singleCollateralValueInDsc = (dsce.getUSDValue(weth, 1 ether) *
            2) / 3;
        console.log("amount of dsc to mint ", singleCollateralValueInDsc);

        vm.startPrank(aayush);
        ERC20Mock(weth).approve(address(dsce), 1000 ether);
        vm.expectRevert();
        dsce.depositCollateralAndMintDsc(
            weth,
            1 ether,
            singleCollateralValueInDsc
        );
        vm.stopPrank();

        console.log("Here is the balance", dsc.balanceOf(aayush));
    }

    function testDepositCollateralAndMintWithoutApprove() public {
        uint256 singleCollateralValueInDsc = dsce.getUSDValue(weth, 1 ether) /
            2;
        console.log("amount of dsc to mint ", singleCollateralValueInDsc);

        vm.startPrank(aayush);
        // ERC20Mock(weth).approve(address(dsce), 1000 ether);
        vm.expectRevert();
        dsce.depositCollateralAndMintDsc(
            weth,
            1 ether,
            singleCollateralValueInDsc
        );
        vm.stopPrank();

        console.log("Here is the balance", dsc.balanceOf(aayush));
    }

    function testDepositCollateralAndMintLessDSCThenMintRemaining() public {
        uint256 singleCollateralValueInDsc = dsce.getUSDValue(weth, 1 ether) /
            3;
        console.log("amount of dsc to mint ", singleCollateralValueInDsc);

        vm.startPrank(aayush);
        ERC20Mock(weth).approve(address(dsce), 1000 ether);

        dsce.depositCollateralAndMintDsc(
            weth,
            1 ether,
            singleCollateralValueInDsc
        );
        vm.stopPrank();

        console.log("Here is the balance", dsc.balanceOf(aayush));

        vm.startPrank(aayush);
        dsce.mintDsc(singleCollateralValueInDsc / 2); //since 1/2-1/3 is 1/6 so i just divided by 2 to get remaining

        vm.stopPrank();

        console.log("Here is the balance", dsc.balanceOf(aayush));
    }

    function testDepositCollateralAndMintLessDSCThenMintRemainingThenMoreThanAllowed()
        public
    {
        uint256 singleCollateralValueInDsc = dsce.getUSDValue(weth, 1 ether) /
            3;
        console.log("amount of dsc to mint ", singleCollateralValueInDsc);

        vm.startPrank(aayush);
        ERC20Mock(weth).approve(address(dsce), 1000 ether);

        dsce.depositCollateralAndMintDsc(
            weth,
            1 ether,
            singleCollateralValueInDsc
        );
        vm.stopPrank();

        console.log("Here is the balance", dsc.balanceOf(aayush));

        vm.startPrank(aayush);
        dsce.mintDsc(singleCollateralValueInDsc / 2); //since 1/2-1/3 is 1/6 so i just divided by 2 to get remaining

        vm.stopPrank();

        console.log("Here is the balance", dsc.balanceOf(aayush));

        vm.startPrank(aayush);
        vm.expectRevert();
        dsce.mintDsc(singleCollateralValueInDsc / 2);

        vm.stopPrank();
    }

    function testRedeemCollateraForDSC() public {
        uint256 singleCollateralValueInDsc = dsce.getUSDValue(weth, 1 ether) /2;
        console.log("amount of dsc to mint ", singleCollateralValueInDsc);

        vm.startPrank(aayush);
        ERC20Mock(weth).approve(address(dsce), 2 ether);
        // vm.expectRevert();
        dsce.depositCollateralAndMintDsc(
            weth,
            1 ether,
            singleCollateralValueInDsc
        );
        vm.stopPrank();

        console.log("Here is the balance", dsc.balanceOf(aayush));


        vm.startPrank(aayush);
        ERC20Mock(address(dsc)).approve(address(dsce), 1000 ether);
        dsce.redeemCollateralForDsc(
            weth,
               33e16,  //appproc one-third 
            singleCollateralValueInDsc/3

        );
        vm.stopPrank();



    }
    function testRedeemCollateraForDSCRevertOnAskingMoreCollateral() public {
        uint256 singleCollateralValueInDsc = dsce.getUSDValue(weth, 1 ether) /2;
        console.log("amount of dsc to mint ", singleCollateralValueInDsc);

        vm.startPrank(aayush);
        ERC20Mock(weth).approve(address(dsce), 2 ether);
        // vm.expectRevert();
        dsce.depositCollateralAndMintDsc(
            weth,
            1 ether,
            singleCollateralValueInDsc
        );
        vm.stopPrank();

        console.log("Here is the balance", dsc.balanceOf(aayush));


        vm.startPrank(aayush);
        ERC20Mock(address(dsc)).approve(address(dsce), 1000 ether);
        vm.expectRevert();
        dsce.redeemCollateralForDsc(
            weth,
               34e16,  //appproc one-third 
            singleCollateralValueInDsc/3

        );
        vm.stopPrank();



    }
    function testRedeemCollateraForDSCRevertOnBurningLessDSCAndAskingMoreCollateral() public {
        uint256 singleCollateralValueInDsc = dsce.getUSDValue(weth, 1 ether) /2;
        console.log("amount of dsc to mint ", singleCollateralValueInDsc);

        vm.startPrank(aayush);
        ERC20Mock(weth).approve(address(dsce), 2 ether);
        // vm.expectRevert();
        dsce.depositCollateralAndMintDsc(
            weth,
            1 ether,
            singleCollateralValueInDsc
        );
        vm.stopPrank();

        console.log("Here is the balance", dsc.balanceOf(aayush));


        vm.startPrank(aayush);
        ERC20Mock(address(dsc)).approve(address(dsce), 1000 ether);
        vm.expectRevert();
        dsce.redeemCollateralForDsc(
            weth,
               34e16,  //appproc one-third  is asked which is more that dsc burned for it
            singleCollateralValueInDsc/4

        );
        vm.stopPrank();



    }
}
// 1e21 is dsc to mint
//amount is 2e21 after adjustment its 1e21

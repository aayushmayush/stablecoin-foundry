//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

interface DSCEngineErrors {
    error DSCEngine_NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesLengthMustBeNonZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__DscAddressShouldBeNonZero();
    error DSCEngine__ShouldBeAContract();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeNonZero();
    error DSCEngine_TokenNotAllowed(address token);
    error DSCEngine__TransferFailed();
    error DSCEngine__BreaksHealthFactor(uint256 userHealthFactor);
    error DSCEngine__MintFailed();
    error DSCEngine__HealthFactorOk();
    error DSCEngine__HealthFactorNotImproved();
}

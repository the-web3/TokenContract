// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";


contract TheWebThreeToken is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, OwnableUpgradeable, ERC20PermitUpgradeable {
    /* ========== STATE VARIABLES ========== */
    string private constant NAME = "DappLink";
    string private constant SYMBOL = "DLK";

    /// @dev The minimum amount of time that must elapse before a mint is allowed
    uint256 public constant MIN_MINT_INTERVAL = 365 days;

    /// @dev The denominator of the maximum fractional amount that can be minted
    uint256 public constant MINT_CAP_DENOMINATOR = 10_000;

    /// @dev The numerator of the maximum fractional amount that can be minted
    uint256 public constant MINT_CAP_MAX_NUMERATOR = 200;

    /// @dev The current numerator of the fractional amount that can be minted
    uint256 public mintCapNumerator;

    /// @dev The blockTimeStamp at which mint will be able to be called again
    uint256 public nextMint;

    /* ========== EVENTS ========== */

    /// @dev Emitted when the mintCapNumerator is set
    /// @param from The address which changed the mintCapNumerator
    /// @param previousMintCapNumerator The previous mintCapNumerator
    /// @param newMintCapNumerator The new mintCapNumerator
    event MintCapNumeratorChanged(address indexed from, uint256 previousMintCapNumerator, uint256 newMintCapNumerator);

    /* ========== ERRORS ========== */
    /// @notice Thrown when at least one of the inputs passed into the constructor is a zero value
    error DappLinkToken_ImproperlyInitialized();

    /// @notice Thrown when mint is called before the nextMint timestamp has passed
    error DappLinkToken_NextMintTimestampNotElapsed(uint256 currentTimestamp, uint256 nextMintTimestamp);

    /// @notice Thrown when mint is called with a value greater than the maximum allowed
    error DappLinkToken_MintAmountTooLarge(uint256 amount, uint256 maximumAmount);

    /// @notice Thrown when the mintCapNumerator is set to a value greater than the maximum allowed
    error DappLinkToken_MintCapNumeratorTooLarge(uint256 numerator, uint256 maximumNumerator);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /* ========== INITIALIZER ========== */

    /// @notice Initializes the TheWebThreeToken.sol contract, setting the inital total supply as {initialSupply} and the owner as {_owner}
    /// @dev the mintCapNumerator should not be set as it is initialized as 0
    /// @dev Requirements:
    ///     - all parameters must be non-zero
    /// @param _initialSupply The initial total supply of the token
    /// @param _owner The owner of the token
    function initialize(uint256 _initialSupply, address _owner) public initializer {
        if (_initialSupply == 0 || _owner == address(0)) revert DappLinkToken_ImproperlyInitialized();

        __ERC20_init(NAME, SYMBOL);
        __ERC20Burnable_init();
        __Ownable_init(_owner);
        __ERC20Permit_init(NAME);

        _mint(_owner, _initialSupply);
        nextMint = block.timestamp + MIN_MINT_INTERVAL;

        _transferOwnership(_owner);
    }

    /// @notice Allows the owner to mint new tokens and increase this token's total supply
    /// @dev Requirements:
    ///     - Only allows minting below an inflation cap at a specified time interval
    ///         - The max mint amount is computed as follows:
    ///             - maxMintAmount = (mintCapNumerator * totalSupply()) / MINT_CAP_DENOMINATOR
    ///              - The specified time interval at which mints can occur is 1 year (365 days)
    ///     - the parameter {amount} must be less than or equal to {maxMintAmount} as computed above
    ///     - the {blockTimestamp} of the block in which this function is called must be greater than or equal to {nextMint}
    /// @param _recipient The address to mint tokens to
    /// @param _amount The amount of tokens to mint
    function mint(address _recipient, uint256 _amount) public onlyOwner {
        uint256 maximumMintAmount = (totalSupply() * mintCapNumerator) / MINT_CAP_DENOMINATOR;
        if (_amount > maximumMintAmount) {
            revert DappLinkToken_MintAmountTooLarge(_amount, maximumMintAmount);
        }
        if (block.timestamp < nextMint) revert DappLinkToken_NextMintTimestampNotElapsed(block.timestamp, nextMint);

        nextMint = block.timestamp + MIN_MINT_INTERVAL;
        super._mint(_recipient, _amount);
    }

    /// @notice Allows the owner to set the mintCapNumerator
    /// @dev emits a {MintCapNumeratorChanged} event
    /// @dev Requirements:
    ///     - The caller must be the contract owner
    ///     - {_mintCapNumerator} must be less than or equal to {MINT_CAP_MAX_NUMERATOR}
    /// @param _mintCapNumerator The new numerator of the mint cap
    function setMintCapNumerator(uint256 _mintCapNumerator) public onlyOwner {
        if (_mintCapNumerator > MINT_CAP_MAX_NUMERATOR) {
            revert DappLinkToken_MintCapNumeratorTooLarge(_mintCapNumerator, MINT_CAP_MAX_NUMERATOR);
        }
        emit MintCapNumeratorChanged(msg.sender, mintCapNumerator, _mintCapNumerator);
        mintCapNumerator = _mintCapNumerator;
    }
}
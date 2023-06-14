// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "./Interfaces/IERC20.sol";
import "./Interfaces/IUniswapV2Pair.sol";
import "./Interfaces/IUniswapV2Router.sol";

/// @title Task2 - Getting live market prices
/// @author Bahador Ghadamkheir
/// @notice Analyzing in real-time and totally with smart contracts, is somehow risky and I guess it is not as efficient. 
///we may be able to sync smart contract with a backend code.
contract PriceChecker is ConfirmedOwner {
    AggregatorV3Interface internal btcPriceFeed;
    AggregatorV3Interface internal ethPriceFeed;
    AggregatorV3Interface internal theTokenPriceFeed;
    uint256 public ethBalance;
    uint256 public btcBalance;
    int256 public initialBtcPrice;
    int256 public initialEthPrice;

    event Trade(address SellingTokenAddress, address BuyingTokenAddress, uint VolumeSold, uint VolumeBought);

    /// @notice Constructor will initialize our needed Price Feeds
    constructor() ConfirmedOwner(msg.sender) {
        // Replace these with the address of the price feed contract for each cryptocurrency you want to track
        btcPriceFeed = AggregatorV3Interface(0x65E8d79f3e8e36fE48eC31A2ae935e92F5bBF529);
        ethPriceFeed = AggregatorV3Interface(0xB8C458C957a6e6ca7Cc53eD95bEA548c52AFaA24);

        // Store the initial price of Bitcoin
        (, initialBtcPrice, , , ) = btcPriceFeed.latestRoundData();

        // Store the initial price of Ethereum
        (, initialEthPrice, , , ) = ethPriceFeed.latestRoundData();
    }

    /// @notice We get current Bitcoin price
    /// @return Bitcoin's latest price will be returns as an int value
    function getBtcPrice() public view returns (int) {
        (, int price, , ,) = btcPriceFeed.latestRoundData();
        return price;
    }

    /// @notice We get current Ethereum price
    /// @return Ether's latest price will be returns as an int value
    function getEthPrice() public view returns (int) {
        (, int price, , ,) = ethPriceFeed.latestRoundData();
        return price;
    }

    /// @notice We get current user defined token price
    /// @return (user defined token)'s latest price will be returns as an int value
    function getTheTokenPrice() public view returns (int) {
        (, int price, , ,) = theTokenPriceFeed.latestRoundData();
        return price;
    }

    /// @notice This function will do swaping operation
    /// @param router Address of dex router
    /// @param _tokenIn Address of selling token
    /// @param _tokenOut Address of buying token
    /// @param _amount Volume of selling
	function swap(address router, address _tokenIn, address _tokenOut, uint256 _amount) private {
        // No need to mention, in order to make the swapping, we first have to approve dex contract to spend the contract ERC20 tokens
		IERC20(_tokenIn).approve(router, _amount);
		address[] memory path;
        // Defining Liquidity path
		path = new address[](2);
		path[0] = _tokenIn;
		path[1] = _tokenOut;
        // Transaction will be declined if not done after deadline time
		uint deadline = block.timestamp + 300;
		IUniswapV2Router(router).swapExactTokensForTokens(_amount, 1, path, address(this), deadline);
	}

    /// @notice
    /// @param router Address of dex router
    /// @param _tokenIn Address of selling token
    /// @param _tokenOut Address of buying token
    /// @param _amount Volume of selling
    /// @return Minimum amount out of buying token
	 function getAmountOutMin(address router, address _tokenIn, address _tokenOut, uint256 _amount) public view returns (uint256) {
		address[] memory path;
		path = new address[](2);
		path[0] = _tokenIn;
		path[1] = _tokenOut;
		uint256[] memory amountOutMins = IUniswapV2Router(router).getAmountsOut(_amount, path);
		return amountOutMins[path.length -1];
	}

    /// @notice Trade function is for making desicion and sending transaction
    /// @param _router1 Address of dex router
    /// @param _token1 Address of selling token
    /// @param _token2 Address of buying token
    /// @param _amount Volume of selling
    function trade(address _router1, address _token1, address _token2, uint256 _amount) public onlyOwner {
        int btcPrice = getBtcPrice();
        // If price of Bitcoin goes down by 2%
        if (((initialBtcPrice - btcPrice) * 100) / initialBtcPrice >= 2) {
            uint token1startBalance = IERC20(_token1).balanceOf(address(this));
            uint token2InitialBalance = IERC20(_token2).balanceOf(address(this));
            swap(_router1,_token1, _token2, _amount);
            uint token2EndBalance = IERC20(_token2).balanceOf(address(this));
            uint token1EndBalance = IERC20(_token1).balanceOf(address(this));
            emit Trade(_token1, _token2, token1startBalance, token2EndBalance);
        }
    }

    /// @notice This function can estimate minimum amount out of buying token
    /// @param _router Address of dex router
    /// @param _token1 Address of selling token
    /// @param _token2 Address of buying token
    /// @param _amount Volume of selling
    /// @return amtBack Minimum volume of buying token amount out
    function estimateTrade(address _router, address _token1, address _token2, uint256 _amount) external view returns (uint256 amtBack) {
            amtBack = getAmountOutMin(_router, _token1, _token2, _amount);
        }

    /// @notice Depositing Ether into the contract
    function depositEth() public payable {
        ethBalance += msg.value;
    }

    /// @notice Withdrawing contract Ether's balance
    function withdrawEth() public {
        payable(msg.sender).transfer(ethBalance);
        ethBalance = 0;
    }

    /// @notice Getting contract's Ether balance
    /// @return Ether's balance
    function getEthBalance() public view returns (uint256) {
        return ethBalance;
    }

    /// @notice Getting contract's Bitcoin balance
    /// @return Bitcoin's balance
    function getBtcBalance() public view returns (uint256) {
        return btcBalance;
    }

    /// @notice With this function , owner can set a new token
    /// @param _theTokenPriceFeed Address of new token
    /// @dev Altought here we just defined one new token. but we can make multiple new tokens. for example with defining mapping
    function setTheTokenAddress(address _theTokenPriceFeed) public onlyOwner {
        theTokenPriceFeed = AggregatorV3Interface(_theTokenPriceFeed);
    }

    /// @notice To get balance of specific ERC20 token in this smart contract
    /// @param _tokenContractAddress ERC20 token address
	function getBalance (address _tokenContractAddress) external view  returns (uint256) {
		uint balance = IERC20(_tokenContractAddress).balanceOf(address(this));
		return balance;
	}

    /// @notice To withdraw tokens in this smart contract
    /// @param tokenAddress ERC20 token address
	function recoverTokens(address tokenAddress) external onlyOwner {
		IERC20 token = IERC20(tokenAddress);
		token.transfer(msg.sender, token.balanceOf(address(this)));
	}

    /// @notice Fallback function to transact with functions with just function's methodId
    /// @dev Nothing special here. just for fun
    fallback() external payable {
        (bool success, ) = address(this).call{gas: 10000}(abi.encodeWithSelector(bytes4(msg.data)));
        require(success);
    }
    
}
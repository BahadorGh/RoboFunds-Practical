
/// @notice I just want this part of IUniswapV2Pair interface on my PriceChecker contract.
interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(uint256 amount0Out,	uint256 amount1Out,	address to,	bytes calldata data) external;
}
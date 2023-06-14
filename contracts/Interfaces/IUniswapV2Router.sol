/// @notice Just need this part of IUniswapV2Router interface to maek swaping of my desired tokens.
/// As we are working on tokens to tokens swaping(WETH -> token).
/// If we want to swap Native ETH to token, we have to use swapExactETHForTokens.
interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
  function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
}
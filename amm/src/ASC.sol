// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract AggregatedStableCoin {
    // Declare state variables
    IERC20 public dai;
    IERC20 public usdc;
    IERC20 public usdt;
    mapping(address => uint256) public balances;

    // Initialize the contract with the addresses of DAI, USDC, and USDT
    constructor(address _dai, address _usdc, address _usdt) {
        dai = IERC20(_dai);
        usdc = IERC20(_usdc);
        usdt = IERC20(_usdt);
    }

    // Mint new Aggregated Stable Coin (ASC)
    function mint(uint256 amount) external {
        // Transfer DAI, USDC, and USDT from the user to the contract
        require(dai.transferFrom(msg.sender, address(this), amount), "DAI transfer failed");
        require(usdc.transferFrom(msg.sender, address(this), amount), "USDC transfer failed");
        require(usdt.transferFrom(msg.sender, address(this), amount), "USDT transfer failed");

        // Update the user's balance of ASC
        balances[msg.sender] += amount;
    }

    // Redeem Aggregated Stable Coin (ASC)
    function redeem(uint256 amount) external {
        // Check that the user has enough ASC
        require(balances[msg.sender] >= amount, "Insufficient ASC balance");

        // Transfer DAI, USDC, and USDT from the contract to the user
        require(dai.transfer(msg.sender, amount), "DAI transfer failed");
        require(usdc.transfer(msg.sender, amount), "USDC transfer failed");
        require(usdt.transfer(msg.sender, amount), "USDT transfer failed");

        // Update the user's balance of ASC
        balances[msg.sender] -= amount;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract PepeInu is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;

    bool private swapping;

    address payable public devWallet;
    uint256 public taxFee = 5; // 5% tax rate
    uint256 public burnFee = 0; // 0% burn rate
    uint256 public swapTokensAtAmount = 100000 * 10 ** decimals(); // Minimum tokens required for swap
    uint256 public maxTransfer = 100000000 * 10 ** decimals(); // Maximum transfer limit

    mapping(address => bool) private _isExcludedFromFees;

    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);


    constructor() ERC20("Pepe Inu", "PEPINU") {
        devWallet = payable(msg.sender);
        _mint(msg.sender, 469000000 * 10 ** decimals());

         // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
    }

    receive() external payable {
        // Receive ETH
    }

    function setUniswapV2Router(address _router) external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(_router);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "PAN: Account is already excluded");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setDevWallet(address payable wallet) external onlyOwner {
        devWallet = wallet;
    }

    function setSwapAtAmount(uint256 value) external onlyOwner {
        swapTokensAtAmount = value;
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
         super._transfer(from, to, 0);
        return;
    }

    uint256 contractTokenBalance = balanceOf(address(this));
    bool canSwap = contractTokenBalance >= swapTokensAtAmount;

    if (canSwap && !swapping && from != owner() && to != owner()) {
        swapping = true;

        uint256 tokensToSwap = swapTokensAtAmount;
        swapAndSendToFee(tokensToSwap);

        swapping = false;
    }

    bool takeFee = !swapping;

    // Exclude accounts from fees
    if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
        takeFee = false;
    }

    if (takeFee) {
        require(amount <= maxTransfer, "Transfer amount exceeds the maximum limit"); 
        uint256 taxAmount = amount.mul(taxFee).div(1000);
        uint256 burnAmount = amount.mul(burnFee).div(1000);
        uint256 transferAmount = amount.sub(taxAmount).sub(burnAmount);

        super._transfer(from, address(this), taxAmount);
        super._transfer(from, address(0xdead), burnAmount);
        super._transfer(from, to, transferAmount);
    } else {
        super._transfer(from, to, amount);
    }
}

function setTaxFee(uint256 _taxFee) public onlyOwner {
    taxFee = _taxFee;
}

function setBurnFee(uint256 _burnFee) public onlyOwner {
    burnFee = _burnFee;
}

function setMaxTransfer(uint256 _maxTransfer) public onlyOwner {
    maxTransfer = _maxTransfer;
}

function renounceOwnership() public override onlyOwner {
    super.renounceOwnership();
}

function swapAndSendToFee(uint256 tokens) private {
    uint256 initialBalance = address(this).balance;
    swapTokensForETH(tokens);
    uint256 newBalance = address(this).balance.sub(initialBalance);

    devWallet.transfer(newBalance);
}

function swapTokensForETH(uint256 tokenAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();

    _approve(address(this), address(uniswapV2Router), tokenAmount);

    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        tokenAmount,
        0,
        path,
        address(this),
        block.timestamp
    );
}
}

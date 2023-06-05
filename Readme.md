Tested Contract: https://testnet.bscscan.com/token/0x71f31245604d78e637dc7f5f611b06121669a2d3

Here's a summary of the functions and features of the provided contract:

ERC20 Token: The contract extends the ERC20 token contract from the OpenZeppelin library, creating a custom token called "Pepe Inu" with the symbol "PEPINU".

Token Minting: The contract mints an initial supply of 469,000,000 PEPINU tokens to the deployer's address.

Ownership: The contract inherits from the Ownable contract, allowing the owner to perform administrative tasks.

Fees and Exclusions:

Tax Rate: The contract has a configurable tax rate of 5%.
Burn Rate: The contract has a configurable burn rate of 0% (no tokens burned).
Exclusion from Fees: The owner can exclude specific accounts from paying fees or having a maximum transaction amount.
Maximum Transfer Limit: The owner can set a maximum transfer limit for each transaction.
Uniswap Integration:

Router Configuration: The owner can set the address of the Uniswap V2 Router contract.
Swapping Tokens: When the contract holds a minimum token balance (swapTokensAtAmount), it can automatically swap tokens for ETH to collect fees.
Swapping Process:
Tokens are swapped for ETH using the Uniswap V2 Router's swapExactTokensForETHSupportingFeeOnTransferTokens function.
The received ETH is sent to the devWallet address.
Transfer Function Override: The _transfer function is overridden to include fee calculations and token burning.

Fee Calculation: When a transfer occurs, if fees are applicable, a portion of the transferred tokens is taken as a tax fee, and another portion is burned.
Transfer Limit: The transfer amount must not exceed the maximum transfer limit.
Token Burning: Users can burn their own tokens by calling the burn function, specifying the amount to burn.

Configuration Functions:

setTaxRate: The owner can set the tax rate for fee calculations.
setBurnRate: The owner can set the burn rate for token burning.
setMaxTransfer: The owner can set the maximum transfer limit.
Ownership Renouncement: The owner can renounce their ownership, transferring ownership to address(0).

Please note that this summary provides an overview of the contract's functions and features. It's always recommended to perform a thorough review and audit of the contract code before usage.

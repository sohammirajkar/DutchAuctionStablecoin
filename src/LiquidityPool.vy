# File: src/LiquidityPool.vy

from vyper.interfaces import ERC20

event Swap:
    buyer: indexed(address)
    sold_token: indexed(address)
    bought_token: indexed(address)
    sold_amount: uint256
    bought_amount: uint256

event AddLiquidity:
    provider: indexed(address)
    token: indexed(address)
    amount: uint256
    liquidity: uint256

event RemoveLiquidity:
    provider: indexed(address)
    token: indexed(address)
    amount: uint256
    liquidity: uint256

token: public(address)
stablecoin: public(address)
total_liquidity: public(uint256)
liquidity_of: public(HashMap[address, uint256])

@external
def __init__(_token: address, _stablecoin: address):
    self.token = _token
    self.stablecoin = _stablecoin
    self.total_liquidity = 0

@external
def add_liquidity(token_amount: uint256, stablecoin_amount: uint256):
    assert token_amount > 0 and stablecoin_amount > 0, "Invalid amounts"

    ERC20(self.token).transferFrom(msg.sender, self, token_amount)
    ERC20(self.stablecoin).transferFrom(msg.sender, self, stablecoin_amount)

    self.total_liquidity += stablecoin_amount
    self.liquidity_of[msg.sender] += stablecoin_amount
    log AddLiquidity(msg.sender, self.stablecoin, stablecoin_amount, self.total_liquidity)

@external
def remove_liquidity(amount: uint256):
    assert amount > 0 and amount <= self.liquidity_of[msg.sender], "Invalid amount"

    stablecoin_amount = amount
    token_amount = (ERC20(self.token).balanceOf(self) * stablecoin_amount) / self.total_liquidity
    ERC20(self.token).transfer(msg.sender, token_amount)
    ERC20(self.stablecoin).transfer(msg.sender, stablecoin_amount)

    self.total_liquidity -= stablecoin_amount
    self.liquidity_of[msg.sender] -= stablecoin_amount
    log RemoveLiquidity(msg.sender, self.stablecoin, stablecoin_amount, self.total_liquidity)

@external
def swap(sell_token: address, buy_token: address, amount: uint256):
    assert amount > 0, "Invalid amount"
    if sell_token == self.token and buy_token == self.stablecoin:
        token_amount = amount
        stablecoin_amount = self.get_swap_amount(token_amount)
        ERC20(self.token).transferFrom(msg.sender, self, token_amount)
        ERC20(self.stablecoin).transfer(msg.sender, stablecoin_amount)
        log Swap(msg.sender, self.token, self.stablecoin, token_amount, stablecoin_amount)
    elif sell_token == self.stablecoin and buy_token == self.token:
        stablecoin_amount = amount
        token_amount = self.get_swap_amount(stablecoin_amount)
        ERC20(self.stablecoin).transferFrom(msg.sender, self, stablecoin_amount)
        ERC20(self.token).transfer(msg.sender, token_amount)
        log Swap(msg.sender, self.stablecoin, self.token, stablecoin_amount, token_amount)
    else:
        raise "Invalid token pair"

@view
def get_swap_amount(input_amount: uint256) -> uint256:
    return input_amount * 997 // 1000  # Example swap calculation with 0.3% fee

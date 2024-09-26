
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Context.sol)
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner_, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// OpenZeppelin Contracts (last updated v4.4.1) (token/ERC20/extensions/IERC20Metadata.sol)
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner_ = _msgSender();
        _transfer(owner_, to, amount);
        return true;
    }

    function allowance(address owner_, address spender) public view virtual override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner_ = _msgSender();
        _approve(owner_, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner_ = _msgSender();
        _approve(owner_, spender, _allowances[owner_][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner_ = _msgSender();
        uint256 currentAllowance = _allowances[owner_][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner_, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner_, address spender, uint256 amount) internal virtual {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function _spendAllowance(address owner_, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner_, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner_, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// Interface pro Uniswap Router
interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    
    // Přidání likvidity
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

// Interface pro Uniswap Factory
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// Váš hlavní kontrakt Etherwar
contract Etherwar is ERC20, Ownable, ReentrancyGuard {
    // Maximální nabídka tokenů (100 milionů)
    uint256 public constant MAX_SUPPLY = 1000_000_000 * 10 ** 18;

    // Počáteční nabídka (10%)
    uint256 public initialSupply = MAX_SUPPLY / 10; // 100 milionů

    // Zbývající tokeny k uvolnění
    uint256 public releaseAmount = MAX_SUPPLY - initialSupply; // 90 milionů

    // Počet transakcí pro uvolnění tokenů
    uint256 public releaseCycle = 10000000; // Nastavte podle potřeby
    uint256 public transactionCount = 0;

    // Poplatky v procentech
    uint256 public marketFee = 99; // 2%
    uint256 public buyFee = 1;    // 3%
    uint256 public sellFee = 1;   // 3%
    uint256 public burnFee = 1;   // 1%

    // Adresa tržní peněženky (Marketing)
    address public constant marketWallet = 0xc84A05aE3054D15A20571D02Fc1E37a876242D5D;

    // Uniswap Router a Pair
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    // Whitelist (povolená adresa pro první nákup)
    bool public whitelistEnabled = true;
    address public whitelistAddress = 0x88703E0Ed80E1C7D7B5F91679C7b1B23949448ef;

    // Mapování pro vyjmutí poplatků
    mapping(address => bool) private _isExcludedFromFees;

    // Staking
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public rewardBalance;
    uint256 public rewardRate = 100; // Příklad: 10% ročně (upravte podle potřeby)

    // Události
    event FeesUpdated(uint256 marketFee, uint256 buyFee, uint256 sellFee, uint256 burnFee);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event TokensReleased(uint256 amount);
    event PairCreated(address pair);
    event RouterUpdated(address router);
    event WhitelistDisabled();

    // Konstruktor bez Uniswap interakcí
    constructor() ERC20("Test", "TEST") {
        // Vyjmutí vlastního adresy a Uniswap z poplatků
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[marketWallet] = true;
        
        // Mint počáteční nabídky
        _mint(msg.sender, initialSupply);
    }

    // Funkce pro nastavení Uniswap Router a vytvoření pairu
    function setUniswapRouter(address _router) external onlyOwner {
        require(_router != address(0), "Invalid router address");
        uniswapV2Router = IUniswapV2Router02(_router);

        // Vytvoření Uniswap Pair
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());

        // Vyjmutí pairu z poplatků
        _isExcludedFromFees[uniswapV2Pair] = true;

        emit RouterUpdated(_router);
        emit PairCreated(uniswapV2Pair);
    }

    // Překrytí transfer funkce pro implementaci poplatků, spalování a whitelistu
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        // Ověření whitelistu
        if (whitelistEnabled) {
            require(
                sender == whitelistAddress || recipient == whitelistAddress,
                "Only the whitelisted address can make transfers"
            );
            // Deaktivace whitelistu po prvním nákupu
            whitelistEnabled = false;
            emit WhitelistDisabled();
        }

        // Zkontrolovat, zda je vyjmutí z poplatků
        bool takeFee = true;
        if (_isExcludedFromFees[sender] || _isExcludedFromFees[recipient]) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 fees = 0;

            // Určení typu transakce (nákup/prodej/jiná)
            if (sender == uniswapV2Pair) { // Nákup
                fees = (amount * (buyFee + marketFee + burnFee)) / 100;
            } else if (recipient == uniswapV2Pair) { // Prodej
                fees = (amount * (sellFee + marketFee + burnFee)) / 100;
            } else { // Ostatní transakce
                fees = (amount * marketFee) / 100;
            }

            // Pálení tokenů
            uint256 burnAmount = (amount * burnFee) / 100;
            if (burnAmount > 0) {
                super._burn(sender, burnAmount);
            }

            // Převod poplatků na tržní peněženku
            if (fees > burnAmount) {
                uint256 marketAmount = fees - burnAmount;
                super._transfer(sender, marketWallet, marketAmount);
            }

            // Převod zbytku na příjemce
            super._transfer(sender, recipient, amount - fees);
        } else {
            super._transfer(sender, recipient, amount);
        }

        // Zvýšení počtu transakcí
        transactionCount += 1;

        // Uvolnění tokenů po dosažení cyklu
        if (transactionCount >= releaseCycle && releaseAmount > 0) {
            uint256 releaseTokens = releaseAmount / 10; // Uvolnit 10% zbytkové nabídky
            // Kontrola, aby nedošlo k překročení MAX_SUPPLY
            if (totalSupply() + releaseTokens > MAX_SUPPLY) {
                releaseTokens = MAX_SUPPLY - totalSupply();
            }
            _mint(owner(), releaseTokens);
            releaseAmount -= releaseTokens;
            transactionCount = 0;
            emit TokensReleased(releaseTokens);
        }
    }

    // Funkce pro nastavení poplatků
    function setFees(uint256 _marketFee, uint256 _buyFee, uint256 _sellFee, uint256 _burnFee) external onlyOwner {
        require(_marketFee + _buyFee + _sellFee + _burnFee <= 20, "Total fees must be <= 20%");
        marketFee = _marketFee;
        buyFee = _buyFee;
        sellFee = _sellFee;
        burnFee = _burnFee;
        emit FeesUpdated(_marketFee, _buyFee, _sellFee, _burnFee);
    }

    // Vyjmutí adresy z poplatků
    function excludeFromFees(address account, bool excluded) external onlyOwner {
        _isExcludedFromFees[account] = excluded;
    }

    // Staking funkce
    function stake(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Staking amount must be greater than 0");
        _transfer(msg.sender, address(this), _amount);
        stakingBalance[msg.sender] += _amount;
        emit Staked(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Withdraw amount must be greater than 0");
        require(stakingBalance[msg.sender] >= _amount, "Insufficient staked balance");
        stakingBalance[msg.sender] -= _amount;
        _transfer(address(this), msg.sender, _amount);
        emit Withdrawn(msg.sender, _amount);
    }

    function claimRewards() external nonReentrant {
        uint256 reward = (stakingBalance[msg.sender] * rewardRate) / 1000; // Přizpůsobte rewardRate
        require(reward > 0, "No rewards available");
        _mint(msg.sender, reward);
        rewardBalance[msg.sender] += reward;
        emit RewardClaimed(msg.sender, reward);
    }

    // Přidání likvidity na Uniswap
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) external payable onlyOwner {
        require(msg.value == ethAmount, "ETH amount mismatch");
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Přidání likvidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // minimální množství tokenů
            0, // minimální množství ETH
            owner(),
            block.timestamp
        );
    }

    // Přijetí ETH
    receive() external payable {}
}

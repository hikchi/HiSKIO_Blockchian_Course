// SPDX-License-Identifier: UNLICENSED

/* 定義版本，這邊使用0.8.8 */
pragma solidity ^0.8.0;

/* 引入合約需要的檔案 */
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Ownable.sol";

/* 主合約定義，需要繼承相關檔案們 */
contract Erc20BankBack is IERC20, IERC20Metadata, Ownable {
    /* 在Solidity 0.8.0，若繼承了同名的函式，需要填寫override關鍵字 */

	/* 因為Ownable合約的關係，這個不需要了 */
    // address private owner;

	/* 儲存所有會員的ether餘額 */
    /* IERC20協議中，需要有balance來儲存各個人的餘額 */ 
    /* 這邊我們把他由coin改成balance */
    // mapping (address => uint256) private coin;
    mapping (address => uint256) private balance;

    /* IERC20協議中，需要有allowances來儲存各個人的允許轉帳金額 */ 
    mapping (address => mapping (address => uint256)) private _allowances;


    /* IERC20裡面已經有定義transfer的事件，這邊就不需要了 */
    // event TransferCoinEvent(address indexed from, address indexed to, uint256 value);

    /* 標準ERC20裡面，需要紀錄關於這個token的資訊，比如說總發行量、代幣名稱、代幣代號、小數點位數 */
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimal;

    /* 因為Ownable合約的關係，這個不需要了 */
    // modifier isOwner() {
    //     require(owner == msg.sender, "you are not owner");
    //     _;
    // }

	/* 合約建構式，需要再一開始就給定這個ERC20 Token的一些資訊 */
    constructor(string memory name_, string memory symbol_) {
        /* 因為Ownable合約的關係，這個不需要了 */
        // owner = msg.sender;
        _name = name_;
        _symbol = symbol_;
        _decimal = 18;
        _totalSupply = 0;
    }

    /* IERC20Metadata有三個函式要實作，包含取得token名稱、代號、小數點位數 */
    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() external view virtual override returns (uint8) {
        return _decimal;
    }

    /* IERC20有幾些唯獨函式需要實作，包含取得總發行量、以及取得用戶餘額 */
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view virtual override returns (uint256) {
        return balance[account];
    }

    error InsufficientCoin(uint256 requested, uint256 available);

	/* 轉帳（標準ERC20函式)，把原本的transferCoin改成transfer */
    // function transferCoin(address to, uint coinValue) public {
    function transfer(address to, uint256 coinValue) public virtual override returns (bool) {
        /* 我們不允許to是0地址 */
        require(to != address(0), "transfer to the zero address");

        if (coinValue > balance[msg.sender]){
            revert InsufficientCoin ({
                requested: coinValue,
                available: balance[msg.sender]
            });
        }

        balance[msg.sender] -= coinValue;
        balance[to] += coinValue;

        /* 配合IERC20，只能觸發Transfer事件 */
        // emit TransferCoinEvent(msg.sender, to, coinValue);
        emit Transfer(msg.sender, to, coinValue);
        
        /* IERC20 裡面需要回傳一個布林 */
        return true;
    }

	// 鑄造錢幣，只能由Owner去觸發
    function mint(address receiver, uint amount) public onlyOwner {
        require(amount <= 7414, "No more than 7414 coins per mint");
        balance[receiver] += amount;
    }

    /* 其他IERC20裡面載明的函式 */
    function approve(address spender, uint256 coinValue) external virtual override returns (bool) {
        require(spender != address(0), "approve to the zero address");

        address owner = msg.sender;
        _allowances[owner][spender] = coinValue;
        /* 觸發IERC20裡面說明的Approval事件 */
        emit Approval(owner, spender, coinValue);
        /* IERC20 裡面需要回傳一個布林 */
        return true;
    }

    function allowance(address owner, address spender) external view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address to, uint256 coinValue) external override returns (bool) {
        require(sender != address(0), "transfer to the zero address");
        require(to != address(0), "transfer to the zero address");
        
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= coinValue, "transfer coinValue exceeds allowance");


        require(balance[sender] >= coinValue, "sender's balances are not enough");

        _allowances[sender][msg.sender] -= coinValue;

        balance[sender] -= coinValue;
        balance[to] += coinValue;

        /* 配合IERC20，只能觸發Transfer事件 */
        // emit TransferEvent(msg.sender, to, coinValue, now);
        emit Transfer(sender, to, coinValue);
        /* IERC20 裡面需要回傳一個布林 */
        return true;
    }
}
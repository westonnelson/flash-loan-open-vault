pragma solidity ^0.5.15;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./MakerDAO.sol";
import "./utils/Withdrawable.sol";
// Aave Interfaces
import "./FlashLoanReceiverBase.sol";
import "./interfaces/ILendingPool.sol";

contract MoonFlash is Ownable, Withdrawable, MakerDAO, FlashLoanReceiverBase {

    // FlashLoan Parameters
    // @dev Update to be passed in FlashLoans "_data" variable. 
    address public GEM_JOIN;
    uint    public DAI_BORROW;
    bytes32 public ILK;
    
    /* ------------------------ */
    // Flash Loan Functions
    /* ------------------------ */
    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    )
        external
    {
        require(_amount <= getBalanceInternal(address(this), _reserve), "Invalid balance, was the flashLoan successful?");
        
        // Step 1 - Convert USDC to DAI
        // openETHVault(_amount, DAI_BORROW, ILK);
        openGemVault(GEM_JOIN, ILK, _amount, DAI_BORROW, true);
        
        // Step 2 -  MAKE TRADES
        
        // Step 3 - Close CDP by paying back USDC
        uint256 cdp = getLastCDP(dss_proxy);
        // closeETHVault(cdp, _amount);
        closeGemVault(GEM_JOIN, cdp, _amount);

        // Step 4 - Time to transfer the funds back
        uint totalDebt = _amount.add(_fee);
        require(totalDebt <= getBalanceInternal(address(this), _reserve), "FlashLoan Fee amount not met.");
        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }

    function flashloan(
        uint _amount, // Flash Loan Amount
        address _asset, // Flash Loan Asset
        address _gemJoin, // MakerDAO Token(Gem) Join Address
        uint _borrow, // Amount of DAI to Borrow
        bytes32 _ilk // Maker Ilk Type
    ) public onlyOwner {
        bytes memory _data = "";
        // Save for executeOperation 
        GEM_JOIN = _gemJoin;
        DAI_BORROW = _borrow;
        ILK = _ilk;
        
        // Initialize Lending Pool
        ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
        lendingPool.flashLoan(address(this), _asset, _amount, _data);
    }

    function approveTokenSpender (address _token, address _spender, uint256 _amount) public onlyOwner {
        ERC20 token = ERC20(_token);
        token.approve(_spender, _amount);
    }

    function destroy() public onlyOwner {
        selfdestruct(msg.sender);
    }
}

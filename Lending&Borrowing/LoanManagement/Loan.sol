pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../IERC20.sol";
import "./LoanManagement.sol";

contract Loan {

    modifier calledByLoanManagement {
        require(msg.sender == managementContract, "Invalid caller");
        _;
    }

    // Loan system settings.
    address payable private managementContract;
    address payable private trustToken;

    // Loan settings.
    address public lender;
    address public borrower;
    bool public borrowerIsInitiator;   // whether the borrower or lender initially requested/offered the loan
    bool private initiatorVerified;
    uint256 public principalAmount;
    uint256 public paybackAmount;
    uint256 public contractFee;         // cost of processing the transaction (or amount paid to the management?)
    string public purpose;
    address public collateralToken;
    uint256 public collateralAmount;
    uint256 public duration;
    uint256 public effectiveDate;

    // loanStatus == 0: loan offer/request made.
    // loanStatus == 1: loan offer/request accepted. principal & collateral automatically transferred.
    // loanStatus == 2: loan defaulted. lender has claimed the collateral after the loan expired without repayment.
    uint8 public loanStatus;

    constructor(
        address payable _managementContract,
        address payable _trustToken,
        address _lender,
        address _borrower,
        uint256 _principalAmount,
        uint256 _paybackAmount,
        uint256 _contractFee,
        string memory _purpose,
        address _collateralToken,
        uint256 _collateralAmount,
        uint256 _duration
    ) public {
        managementContract = _managementContract;
        trustToken = _trustToken;
        lender = _lender;
        borrower = _borrower;
        borrowerIsInitiator = (lender == address(0));
        initiatorVerified = true;
        principalAmount = _principalAmount;
        paybackAmount = _paybackAmount;
        contractFee = _contractFee;
        purpose = _purpose;
        collateralToken = _collateralToken;
        collateralAmount = _collateralAmount;
        duration = _duration;
        // Don't set effectiveDate until the loan goes into effect (LenderAd or BorrowerAd is accepted).
        effectiveDate = 0;
        loanStatus = 0;
    }

    /**
     * @notice Called by management contract to update loan's variables when a request is accepted by a lender.
     */
    function managementAcceptLoanRequest(address _lender) external calledByLoanManagement {
        lender = _lender;
        loanStatus = 1;
        effectiveDate = block.timestamp;
    }

    /**
     * @notice Called by management contract to update loan's variables when an offer is accepted by a borrower.
     */
    function managementAcceptLoanOffer(address _borrower) external calledByLoanManagement {
        borrower = _borrower;
        loanStatus = 1;
        effectiveDate = block.timestamp;
    }

    /**
     * @notice Called by LoanManagement to transfer collateral to borrower.
     */
    function managementReturnCollateral() external calledByLoanManagement {
        IERC20(collateralToken).transfer(borrower, collateralAmount);
    }

    /**
     * @notice Called by LoanManagement to transfer collateral to lender.
     */
    function managementDefaultOnLoan() external calledByLoanManagement {
        IERC20(collateralToken).transfer(lender, collateralAmount);
    }

    /**
     * @notice Destroys the loan contract and forwards all remaining funds to the management contract.
     */
    function cleanUp() external calledByLoanManagement {
        selfdestruct(managementContract);
    }

    /**
     * @notice Getter for all loan parameters except trustToken and proposalManagement.
     */
    function getLoanParameters() external view
    returns (LoanInterface.LoanParams memory) {
        return LoanInterface.LoanParams(lender, borrower, initiatorVerified, principalAmount, paybackAmount, contractFee, purpose, collateralToken, collateralAmount, duration, effectiveDate);
    }

    /**
     * @notice Getter for status variables of the loan.
     */
    function getLoanStatus() external view returns (uint8) {
        return (loanStatus);
    }

    /**
     * @notice Non-static getter for status variables of the loan. Checks to update loan status before returning it.
     */
    function refreshAndGetLoanStatus() external returns (uint8) {
        // Check if loan has defaulted.
        if (loanStatus == 1 && block.timestamp > effectiveDate + duration) {
            loanStatus = 2;
        }

        // Return loan status.
        return (loanStatus);
    }
}

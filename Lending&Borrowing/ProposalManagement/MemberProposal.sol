pragma solidity ^0.6.0;

contract MemberProposal {
    mapping(address => bool) private voted;

    address private management;
    address public memberAddress;
    bool public proposalPassed;
    bool public proposalExecuted;
    bool public adding;
    uint8 private majorityMargin;
    uint16 public numberOfVotes;
    uint16 public numberOfPositiveVotes;
    uint256 private minimumNumberOfVotes;

    constructor(
        address _memberAddress,
        bool _adding,
        uint256 _minimumNumberOfVotes,
    // TODO Unused variable: majorityMargin
        uint8 _majorityMargin,
        address _managementContract
    ) public {
        memberAddress = _memberAddress;
        adding = _adding;
        minimumNumberOfVotes = _minimumNumberOfVotes;
        majorityMargin = _majorityMargin;
        management = _managementContract;
    }

    /**
     * @notice destroys the proposal contract and forwards the remaining funds to the management contract
     */
    function kill() external {
        require(msg.sender == management, "invalid caller");
        require(proposalExecuted, "!executed");
        selfdestruct(msg.sender);
    }

    /**
     * @notice Registers a vote for the proposal and triggers execution if conditions are met
     * @param _stance True for a positive vote; false otherwise
     * @param _origin The address of the initial function call
     * @return propPassed True if proposal met the required number of positive votes - false otherwise
     * @return propExecuted True if proposal met the required minimum number of votes - false otherwise
     */
    function vote(bool _stance, address _origin) external returns (bool propPassed, bool propExecuted) {
        // Check input parameters.
        require(msg.sender == management, "invalid caller");
        require(!proposalExecuted, "proposal already executed");
        require(!voted[_origin], "address has already voted on this proposal");

        // Count the vote, updating state variables.
        voted[_origin] = true;
        numberOfVotes += 1;
        if (_stance) {
            numberOfPositiveVotes++;
        }

        // Pass the proposal if it has enough votes.
        bool _propPassed = (numberOfVotes >= minimumNumberOfVotes && (numberOfPositiveVotes / numberOfVotes) >= majorityMargin);

        // Execute the proposal if it was passed.
        bool _propExecuted = proposalExecuted;
        if (_propPassed && !_propExecuted) {
            execute();
            _propExecuted = true;
        }

        // Update state variables.
        propPassed = _propPassed;
        proposalPassed = _propPassed;
        propExecuted = _propExecuted;
        proposalExecuted = _propExecuted;
    }

    /**
     * @notice Executes the proposal and updates the internal state.
     */
    function execute() private view {
        // Ensure proposal wasn't already executed.
        require(!proposalExecuted, "proposal already executed");

        // TODO Add _origin to a variable somewhere in ProposalManagement? The last dev didn't provide any logic for this.
    }
}

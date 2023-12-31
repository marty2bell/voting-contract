// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Election{

    string public name;
    string[] public candidates;
    uint public seats; 
    uint public startTime;
    uint public endTime;

    struct PreferenceVotes {
        uint first;
        uint[] second;
        uint[] third;
    }

    PreferenceVotes[] private candidatePreferenceVotes;

    mapping (address => bool) public voters;
    mapping (address => uint) public approvedVotingCentres;

    uint public votesCast;
    uint public electedVoteThreshold;
    
    constructor(string[] memory electionCandidates, string memory electionName, uint256 numberOfSeats, uint256 electionStartTime, uint256 electionEndTime) {
        name = electionName;
        startTime = electionStartTime;
        endTime = electionEndTime;
        seats = numberOfSeats;
        candidates = electionCandidates;
        // if number of candidates is less than seats then error -> invalid election 
        setupCandidatesForVoting(electionCandidates);
        votesCast = 0;
    }

    function setupCandidatesForVoting(string[] memory electionCandidates) internal {
        // Setup default Voting structures
        uint[] memory initialVoteArray = generateInitialVotingArray(electionCandidates);
        PreferenceVotes memory initialPreferenceVotes = PreferenceVotes({
            first: 0,
            second: initialVoteArray,
            third: initialVoteArray
        });

        // Setup initial Vote Counts for each Candidate
        for (uint256 i = 0; i < electionCandidates.length; i++) {
            candidatePreferenceVotes.push(initialPreferenceVotes);
        }
    }

    // Create an empty array for each candidate with a default of zero votes
    function generateInitialVotingArray(string[] memory electionCandidates) internal pure returns (uint[] memory) {
        uint[] memory initialVotes = new uint[](electionCandidates.length);
        for (uint i = 0; i < electionCandidates.length; i++) {
            initialVotes[i] = 0;
        }
        return initialVotes;
    }

    // return the current number of votes for a given candidate
    function getFirstPreferenceVotes(uint candidateid) public view returns (uint) {
        return candidatePreferenceVotes[candidateid].first;
    }

    // apply vote preferences to the candidate vote counts
    function vote(uint[] memory preferences) external {
        // Validation:
        // Each id must be between 0 and candidates.length
        // Each id must be unique, can't vote for the same candidate twice
        // Valid combinations -> x,y,z;x,y;x
        // The address can be made unique for each vote, but for the sim it will be the same address, so we can add a list of approved votes for special addresses to cover this

        candidatePreferenceVotes[preferences[0]].first++;
        candidatePreferenceVotes[preferences[0]].second[preferences[1]]++;
        candidatePreferenceVotes[preferences[0]].third[preferences[2]]++;
        votesCast++;
    }

    function calculateResult() external returns (uint) {
        // Can only be called by the contract Owner after the end time has passed
        // Can also only be called once
        electedVoteThreshold = votesCast / seats;
        // if the elected threshold is 0 or less than 1 then error -> election is invalid
        uint candidatesElected = 0;
        bool moreCandidatesToElect = true;
        bool candidateElected;
        while (moreCandidatesToElect) {
            candidateElected = electCandidate();
            if (candidateElected) {
                candidatesElected++;
            }
            if (candidatesElected == seats || candidateElected == false) {
                moreCandidatesToElect = false;
            }
        }
        return candidatesElected;
    }

    function electCandidate() private returns (bool) {
    }

}

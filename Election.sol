// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Election{

    string public name;
    string[] public candidates;
    uint public seats; 
    uint public startTime;
    uint public endTime;

    struct PreferenceVotes {
        bool elected;
        bool eliminated;
        uint round;
        uint first;
        uint firstTransfers;
        uint[] second;
        uint[] secondTransfers;
        uint[] third;
    }

    PreferenceVotes[] private candidatePreferenceVotes;

    mapping (address => bool) public voters;
    mapping (address => uint) public approvedVotingCentres;

    uint public votesCast;
    uint public quota;
    
    // Need to add events for elected and elinminated

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
            elected: false,
            eliminated: false,
            round: 0,
            first: 0,
            firstTransfers: 0,
            second: initialVoteArray,
            secondTransfers: initialVoteArray,
            third: initialVoteArray
        });

        // Setup initial Vote Counts for each Candidate
        for (uint i = 0; i < electionCandidates.length; i++) {
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

    // will calculate the result of the election by working out which candidates made the quota of votes
    // returns the number of candidates elected
    function calculateResults() external returns (uint) {
        // Can only be called by the contract Owner after the end time has passed
        // Can also only be called once
        quota = votesCast / seats;
        // if the elected threshold is 0 or less than 1 then error -> election is invalid
        uint candidatesElected = 0;
        uint votingRound = 1;
        while (candidatesElected < seats) {
            candidatesElected += processVotingRound(votingRound);
        }
        return candidatesElected;
    }


    // Process any Candidates that have reached the quota to be elected
    // Are there more candidates remaining than seats ->
    //  IF YES then eliminate candidate with lowest number of votes
    //  ELSE Elect remaining candidates
    function processVotingRound(uint votingRound) private returns (uint) {
        uint[] memory elected = getCandidatesReachingQuota();
        for (uint i = 0; i < elected.length; i++) {
            processElectedCandidate(elected[i], votingRound);
        }
        return elected.length;
    }

    // Cycle through the candidates and return any that have been elected
    function getCandidatesReachingQuota() private view returns (uint[] memory) {
        uint[] memory candidatesElected;
        uint candidate = 0;

        // Find any candidates that have been elected
        for (uint i = 0; i < candidatePreferenceVotes.length; i++) {
            if (candidatePreferenceVotes[i].first + candidatePreferenceVotes[i].firstTransfers >= quota && candidatePreferenceVotes[i].elected == false && candidatePreferenceVotes[i].eliminated == false) {
                candidatesElected[candidate] = i;
                candidate++;
            }
        }
        return candidatesElected;
    }

    function processElectedCandidate(uint candidate, uint votingRound) private {
        // Set Candidate status -> elected
        // Set the Round thwe candidate was elected in
        // Transfer any second preference votes over the quota to the firstTransfer property of the other candidates
        // Calculate remaining third preference votes (linked to second) to the secondTransfer array of the other candidates
    }

}

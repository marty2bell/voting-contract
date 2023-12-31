// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Election{
    
    struct Candidate{
        uint id;
        string name;
        uint voteCount;
    }


    struct PreferenceVotes {
        uint first;
        uint[] second;
        uint[] third;
    }

    PreferenceVotes[] public candidatePreferenceVotes;

    string[] public candidates;
    uint public candidatesStanding;

    mapping (uint => Candidate) public candidateMap; // may not need

    string private _election_name;

    uint private _candidatesToBeElected; 

    uint private _startTime;

    uint private _endTime;

    mapping (address => bool) public voter;
    
    constructor(string[] memory electionCandidates, string memory election_name, uint256 candidatesToBeElected, uint256 startTime, uint256 endTime) {
        _election_name = election_name;
        _candidatesToBeElected = candidatesToBeElected;
        _startTime = startTime;
        _endTime = endTime;
        candidates = electionCandidates;
        candidatesStanding = electionCandidates.length;
        setupCandidatesForVoting(electionCandidates);
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

    function getFirstPreferenceVotes(uint candidateid) public view returns (uint) {
        return candidatePreferenceVotes[candidateid].first;
    }


    // function initialiseCandidateMapping(string[] memory candidatesStanding) internal {
    //     Candidate memory candidate;
    //     for (uint256 i = 0; i < candidatesStanding.length - 1; i++) {
    //         candidate = Candidate({id: i, name: candidatesStanding[i], voteCount: 0});
    //         candidateMap[i] = candidate;
    //         candidateCount = candidatesStanding.length;
    //     }
    // }

    // function vote(uint _candidateid) public {
    //     require(_candidateid < candidateCount, "Invalid candidate id");
    //     //Access structure from Mapping
    //     Candidate storage candidate = candidateMap[_candidateid];
    //     //Increment vote count
    //     candidate.voteCount++;
    //     //Update structure back in mapping 
    //     candidateMap[_candidateid] = candidate;
    // }

}

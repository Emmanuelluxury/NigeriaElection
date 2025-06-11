// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract NigeriaElection {
    address public admin;

    enum Gender {
        Male,
        Female
    }

    // Structs
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        Gender gender;
    }

    // Array to hold candidates
    Candidate[] public candidates;
    mapping(address => Voter) public voters;
    mapping(Gender => uint256) public genderVoterStats;

    uint256 public totalVotes;

    // Events
    event CandidateRegistered(uint256 indexed candidateId, string name);
    event VoterRegistered(address indexed voter, Gender gender);
    event Voted(address indexed voter, uint256 indexed candidateId);
    event ElectionResults(uint256 indexed candidateId, string name, uint256 voteCount);

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // Modifier to check if the voter is registered
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "You are not a registered voter");
        _;
    }

    // Constructor to set the admin
    constructor() {
        admin = msg.sender;
    }

    // Function to register a candidate
    function registerCandidate(string memory _name) external onlyAdmin {
        candidates.push(Candidate({id: candidates.length, name: _name, voteCount: 0}));
        emit CandidateRegistered(candidates.length - 1, _name);
    }

    // Function to register a voter
    function registerVoter(Gender _gender) external {
        require(!voters[msg.sender].isRegistered, "Already registered");

        voters[msg.sender] = Voter({isRegistered: true, hasVoted: false, gender: _gender});

        genderVoterStats[_gender]++;
        emit VoterRegistered(msg.sender, _gender);
    }

    // Function to allow a registered voter to vote for a candidate
    function vote(uint256 _candidateId) external onlyRegisteredVoter {
        Voter storage voter = voters[msg.sender];
        require(!voter.hasVoted, "You have already voted");
        require(_candidateId < candidates.length, "Invalid candidate");

        candidates[_candidateId].voteCount++;
        voter.hasVoted = true;
        totalVotes++;

        emit Voted(msg.sender, _candidateId);
    }

    // Function to get the list of candidates
    function getCandidates() external view returns (Candidate[] memory) {
        return candidates;
    }

    // Function to get the total number of votes
    function getGenderStats() external view returns (uint256 male, uint256 female) {
        male = genderVoterStats[Gender.Male];
        female = genderVoterStats[Gender.Female];
    }

    // Function to announce the results of the election
    function announceResults() external onlyAdmin {
        for (uint256 i = 0; i < candidates.length; i++) {
            emit ElectionResults(candidates[i].id, candidates[i].name, candidates[i].voteCount);
        }
    }
}

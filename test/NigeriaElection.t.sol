// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NigeriaElection.sol";

contract NigeriaElectionTest is Test {
    NigeriaElection election;
    // Addresses for testing
    address admin = address(0xA11CE);
    address voter1 = address(0xB0B);
    address voter2 = address(0xCAFE);

    function setUp() public {
        vm.prank(admin);
        election = new NigeriaElection();
    }

    function testRegisterCandidate() public {
        vm.startPrank(admin);
        election.registerCandidate("Peter Obi");
        election.registerCandidate("Bola Tinubu");

        NigeriaElection.Candidate[] memory candidates = election.getCandidates();
        assertEq(candidates.length, 2);
        assertEq(candidates[0].name, "Peter Obi");
        assertEq(candidates[1].name, "Bola Tinubu");
        vm.stopPrank();
    }

    function testRegisterVoter() public {
        // Register voter1
        vm.prank(voter1);
        election.registerVoter(NigeriaElection.Gender.Male);

        // Register voter2
        vm.prank(voter2);
        election.registerVoter(NigeriaElection.Gender.Female);

        // Check if they are registered
        (bool isReg1,,) = election.voters(voter1);
        (bool isReg2,,) = election.voters(voter2);

        assertTrue(isReg1);
        assertTrue(isReg2);
    }

    function testVote() public {
        // Register candidates first
        vm.prank(admin);
        election.registerCandidate("Peter Obi");
        vm.prank(admin);
        election.registerCandidate("Bola Tinubu");

        // Register voter1
        vm.prank(voter1);
        election.registerVoter(NigeriaElection.Gender.Male);

        // Cast a vote
        vm.prank(voter1);
        election.vote(0); // Voting for Peter Obi (candidate ID 0)

        // Check vote count
        (,, uint256 voteCount) = election.candidates(0);
        assertEq(voteCount, 1);
    }

    function testGetCandidates() public {
        // Register candidates first
        vm.prank(admin);
        election.registerCandidate("Peter Obi");
        vm.prank(admin);
        election.registerCandidate("Bola Tinubu");

        NigeriaElection.Candidate[] memory candidates = election.getCandidates();
        assertEq(candidates.length, 2);
        assertEq(candidates[0].name, "Peter Obi");
        assertEq(candidates[1].name, "Bola Tinubu");
    }

    function testGetGenderStats() public {
        // Register voters
        vm.prank(voter1);
        election.registerVoter(NigeriaElection.Gender.Male);

        vm.prank(voter2);
        election.registerVoter(NigeriaElection.Gender.Female);

        // Get gender stats
        (uint256 male, uint256 female) = election.getGenderStats();

        // Assert stats
        assertEq(male, 1);
        assertEq(female, 1);
    }

    function testAnnounceResults() public {
        // Register candidates first
        vm.prank(admin);
        election.registerCandidate("Peter Obi");

        vm.prank(admin);
        election.registerCandidate("Bola Tinubu");

        // Register voter1 and voter2
        vm.prank(voter1);
        election.registerVoter(NigeriaElection.Gender.Male);

        vm.prank(voter2);
        election.registerVoter(NigeriaElection.Gender.Female);

        // Vote
        vm.prank(voter1);
        election.vote(0); // Peter Obi

        vm.prank(voter2);
        election.vote(1); // Bola Tinubu

        // Announce results
        vm.prank(admin);
        election.announceResults();
    }

    function testOnlyAdminCanRegisterCandidate() public {
        // Attempt to register a candidate as a non-admin
        vm.expectRevert("Only admin can perform this action");
        vm.prank(voter1);
        election.registerCandidate("Atiku Abubakar");
    }

    function testOnlyRegisteredVoterCanVote() public {
        // Attempt to vote without being registered
        vm.expectRevert("You are not a registered voter");
        vm.prank(voter1);
        election.vote(0); // Voting for Peter Obi (candidate ID 0)
    }

    function testCannotVoteTwice() public {
        // Register candidates
        vm.prank(admin);
        election.registerCandidate("Peter Obi");

        vm.prank(admin);
        election.registerCandidate("Bola Tinubu");

        // Register voter1
        vm.prank(voter1);
        election.registerVoter(NigeriaElection.Gender.Male);

        // First vote
        vm.prank(voter1);
        election.vote(0); // Peter Obi

        // Second vote attempt should fail
        vm.prank(voter1);
        vm.expectRevert("You have already voted");
        election.vote(1); // Attempt to vote for Bola Tinubu
    }

    function testCannotVoteForNonExistentCandidate() public {
        // Register voter1
        vm.prank(voter1);
        election.registerVoter(NigeriaElection.Gender.Female);

        // Attempt to vote for a candidate that doesn't exist (index 0, but no candidates registered)
        vm.prank(voter1);
        vm.expectRevert("Invalid candidate");
        election.vote(0);
    }
}

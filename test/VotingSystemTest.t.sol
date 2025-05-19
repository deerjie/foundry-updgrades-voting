// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {VotingSystem} from "../src/VotingSystem.sol";
import {VotingSystemV2} from "../src/VotingSystemV2.sol";
import {ERC1967Proxy} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @title VotingSystemTest
 * @dev Test deployment, functions and upgrade of VotingSystem contract
 */
contract VotingSystemTest is Test {
    // Test accounts
    address public deployer;
    address public voter1;
    address public voter2;
    address public voter3;

    // Contract addresses
    address public proxyAddress;
    address public implementationAddress;
    address public implementationV2Address;

    // Contract instances
    VotingSystem public votingSystem;
    VotingSystemV2 public votingSystemV2;

    // Test constants
    string constant PROPOSAL_DESCRIPTION = "Test Proposal: Increase Community Treasury";
    uint256 constant VOTING_PERIOD = 3 days;

    /**
     * @dev Setup test environment before each test
     */
    function setUp() public {
        // Setup test accounts
        deployer = makeAddr("deployer");
        voter1 = makeAddr("voter1");
        voter2 = makeAddr("voter2");
        voter3 = makeAddr("voter3");

        // Provide ETH to deployer
        vm.deal(deployer, 10 ether);
    }

    /**
     * @dev Test VotingSystem contract deployment
     */
    function testDeployVotingSystem() public {
        vm.startPrank(deployer);
        
        // 1. Deploy implementation contract
        VotingSystem votingSystemImplementation = new VotingSystem();
        implementationAddress = address(votingSystemImplementation);
        
        // 2. Generate initialization data
        bytes memory initializeData = abi.encodeWithSelector(
            VotingSystem.initialize.selector,
            deployer // Set deployer as the initial owner
        );
        
        // 3. Deploy proxy pointing to implementation
        ERC1967Proxy proxy = new ERC1967Proxy(
            implementationAddress,
            initializeData
        );
        proxyAddress = address(proxy);
        
        // Initialize contract instance
        votingSystem = VotingSystem(proxyAddress);
        
        vm.stopPrank();
        
        // Verify addresses are not empty
        assertTrue(proxyAddress != address(0), "Proxy address should not be zero");
        assertTrue(implementationAddress != address(0), "Implementation address should not be zero");
    }

    /**
     * @dev Test VotingSystem contract basic functions
     */
    // function testVotingSystemFunctions() public {
    //     // First deploy the contract
    //     testDeployVotingSystem();
        
    //     // Test creating a proposal
    //     vm.prank(deployer);
    //     votingSystem.createProposal(PROPOSAL_DESCRIPTION, VOTING_PERIOD);
        
    //     // Verify proposal count
    //     assertEq(votingSystem.getProposalCount(), 1, "Should have 1 proposal");
        
    //     // Get proposal and verify data
    //     VotingSystem.Proposal memory proposal = votingSystem.getProposal(0);
    //     assertEq(proposal.description, PROPOSAL_DESCRIPTION, "Proposal description mismatch");
    //     assertEq(proposal.voteCount, 0, "Initial vote count should be 0");
    //     assertEq(proposal.executed, false, "Proposal should not be executed");
        
    //     // Test voting function
    //     vm.prank(voter1);
    //     votingSystem.vote(0);
        
    //     // Verify voting result
    //     proposal = votingSystem.getProposal(0);
    //     assertEq(proposal.voteCount, 1, "Vote count should be 1");
    //     assertTrue(votingSystem.hasVoted(voter1, 0), "Voter1 should have voted");
        
    //     // Test duplicate voting should fail
    //     vm.prank(voter1);
    //     vm.expectRevert("Already voted");
    //     votingSystem.vote(0);
        
    //     // Test pause functionality
    //     vm.prank(deployer);
    //     votingSystem.pause();
        
    //     // Verify cannot vote when paused
    //     vm.prank(voter2);
    //     vm.expectRevert("EnforcedPause()");
    //     votingSystem.vote(0);
        
    //     // Unpause contract
    //     vm.prank(deployer);
    //     votingSystem.unpause();
        
    //     // Verify can vote after unpausing
    //     vm.prank(voter2);
    //     votingSystem.vote(0);
        
    //     // Verify vote is counted
    //     proposal = votingSystem.getProposal(0);
    //     assertEq(proposal.voteCount, 2, "Vote count should be 2");
    // }

    /**
     * @dev Test upgrading VotingSystem contract to V2
     */
    function testUpgradeToV2() public {
        // First deploy the contract
        testDeployVotingSystem();
        
        // Create a proposal and vote
        vm.prank(deployer);
        votingSystem.createProposal(PROPOSAL_DESCRIPTION, VOTING_PERIOD);
        
        vm.prank(voter1);
        votingSystem.vote(0);
        
        // Get initial version
        uint256 initialVersion = votingSystem.getVersion();
        assertEq(initialVersion, 1, "Initial version should be 1");
        
        // Deploy V2 implementation
        vm.startPrank(deployer);
        VotingSystemV2 votingSystemV2Implementation = new VotingSystemV2();
        implementationV2Address = address(votingSystemV2Implementation);
        
        // Perform upgrade
        VotingSystemV2 proxyAsV2 = VotingSystemV2(proxyAddress);
        proxyAsV2.upgradeToAndCall(
            implementationV2Address,
            abi.encodeWithSelector(VotingSystemV2.initializeV2.selector)
        );
        vm.stopPrank();
        
        // Verify upgraded contract
        votingSystemV2 = VotingSystemV2(proxyAddress);
        
        // Verify version has been updated
        uint256 newVersion = votingSystemV2.getVersion();
        assertEq(newVersion, 2, "Updated version should be 2");
        
        // Verify existing data remains unchanged
        VotingSystem.Proposal memory proposal = votingSystemV2.getProposal(0);
        assertEq(proposal.voteCount, 1, "Vote count should still be 1 after upgrade");
        assertTrue(votingSystemV2.hasVoted(voter1, 0), "Voter1's vote should be preserved");
        
        // Test new feature: weighted voting
        vm.prank(deployer);
        votingSystemV2.setVoterWeight(voter2, 3);
        
        // Verify weight is set correctly
        assertEq(votingSystemV2.getVoterWeight(voter2), 3, "Voter2's weight should be 3");
        
        // Use new weighted voting feature
        vm.prank(voter2);
        votingSystemV2.weightedVote(0);
        
        // Verify weighted voting result
        proposal = votingSystemV2.getProposal(0);
        assertEq(proposal.voteCount, 4, "Vote count should be 4 (1 from voter1 + 3 from voter2)");
        
        // Test new feature: cancel proposal
        vm.prank(deployer);
        votingSystemV2.cancelProposal(0);
        
        // Verify proposal is cancelled (deleted)
        proposal = votingSystemV2.getProposal(0);
        assertEq(proposal.voteCount, 0, "Cancelled proposal should have 0 votes");
        assertEq(proposal.description, "", "Cancelled proposal should have empty description");
    }
} 
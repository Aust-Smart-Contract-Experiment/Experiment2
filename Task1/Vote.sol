pragma solidity ^0.6.10;

contract Vote {
    struct Candidate {
        bool exists;
        uint voteCount;
    }

    mapping(address => bool) private voters;
    mapping(address => Candidate) private candidates;
    address[] private candidateList;
    address[] public voterList;
    address[] private winners;

    address public owner;
    bool public votingOpen;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }

    modifier onlyDuringVoting() {
        require(votingOpen, "Voting is not open");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function addCandidates(address[] memory _candidates) public onlyOwner {
        require(_candidates.length > 0, "No candidates provided");
        
        // Clear previous candidate information
        for (uint i = 0; i < candidateList.length; i++) {
            delete candidates[candidateList[i]];
        }
        delete candidateList;

        for (uint i = 0; i < _candidates.length; i++) {
            address candidateAddress = _candidates[i];
            
            candidates[candidateAddress] = Candidate(true, 0);
            candidateList.push(candidateAddress);
        }
        votingOpen = true;
        
        // Reset voters mapping for each new voting session
        clearVotersMapping();
    }

    function vote(address _candidate) public onlyDuringVoting {
        require(!voters[msg.sender], "You have already voted");
        require(candidates[_candidate].exists, "Candidate does not exist");

        candidates[_candidate].voteCount++;
        voters[msg.sender] = true;
        voterList.push(msg.sender);
    }
    
    function clearVotersMapping() internal {
        for (uint i = 0; i < voterList.length; i++) {
            address voterAddress = voterList[i];
            voters[voterAddress] = false;
        }
    }

    function closeVoting() public onlyOwner {
        require(votingOpen, "Voting is already closed");
        votingOpen = false;
        selectWinners();
        clearVotersMapping();
  
    }

    function selectWinners() internal {
        uint maxVotes = 0;
        delete winners;
        
        for (uint i = 0; i < candidateList.length; i++) {
            address candidateAddress = candidateList[i];
            uint votes = candidates[candidateAddress].voteCount;
            if (votes > maxVotes) {
                delete winners;
                winners.push(candidateAddress);
                maxVotes = votes;
            } else if (votes == maxVotes) {
                winners.push(candidateAddress);
            }
        }
    }

    function getAllCandidatesInfo() public view returns (address[] memory, uint[] memory) {
        uint numCandidates = candidateList.length;
        address[] memory addresses = new address[](numCandidates);
        uint[] memory voteCounts = new uint[](numCandidates);

        for (uint i = 0; i < numCandidates; i++) {
            addresses[i] = candidateList[i];
            voteCounts[i] = candidates[candidateList[i]].voteCount;
        }

        return (addresses, voteCounts);
    }

    function getWinners() public view returns (address[] memory) {
        return winners;
    }
}

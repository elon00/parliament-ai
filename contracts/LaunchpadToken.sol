// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ParliamentAIToken
 * @notice Global Deliberative Democracy & Legislative Transparency Launchpad ($PARLIAMENT)
 * @dev Direct micro-escrows for citizen assemblies, public legislative audits, and open democracy
 */
contract ParliamentAIToken {
    string public name = "Parliament AI";
    string public symbol = "PARLIAMENT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    uint256 public constant INITIAL_PRICE = 0.0001 ether;
    uint256 public constant CURVE_SLOPE = 1e10;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event CurveMint(address indexed constituent, uint256 tokenAmount, uint256 ethDonation);
    event DemocracyDisbursement(string indexed legislativeTrack, address indexed recipient, uint256 amountWei, bytes32 indexed billHash);

    function calculateCost(uint256 amount) public view returns (uint256) {
        uint256 currentSupply = totalSupply;
        uint256 baseCost = amount * INITIAL_PRICE;
        uint256 curveFactor = (CURVE_SLOPE * ((currentSupply + amount)**2 - currentSupply**2)) / 2e18;
        return baseCost + curveFactor;
    }

    function mint(uint256 amount) external payable returns (bool) {
        require(amount > 0, "Zero donation amount");
        uint256 cost = calculateCost(amount);
        require(msg.value >= cost, "Insufficient donation for bonding curve");

        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
        emit CurveMint(msg.sender, amount, cost);

        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
        return true;
    }

    function disburseDemocracyGrant(
        string memory legislativeTrack,
        address recipient,
        uint256 amount,
        bytes32 billHash
    ) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient civic treasury reserve");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        emit DemocracyDisbursement(legislativeTrack, recipient, amount, billHash);
        return true;
    }
}

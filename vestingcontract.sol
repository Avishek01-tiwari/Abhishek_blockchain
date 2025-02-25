// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract VestingContract is Ownable {
using SafeMath for uint256;
// SafeMath helps in initializing mathematical terms in code
IERC20 public token;
uint256 public totalAllocatedTokens;
uint256 public start;

enum Role { User, Partner, Team }
//Vesting period: the time during which tokens will be distritubed to the beneficiary accounts.
struct VestingSchedule {
uint256 totalAmount;
//totalAmount: The total number of tokens allocated to the beneficiary.
uint256 cliff;
//cliff: The minimum time that must pass before any tokens can be released.
uint256 duration;
//duration: The total period over which the tokens will vest.
uint256 released;
//released: The amount of tokens that have been already released.
}

mapping(address => VestingSchedule) public beneficiaries;
//Mapping address of the wallet to the Struct VestingSchedule and stores it in beneficiaries (array)
//beneficiaries: refers to the array of accounts registered for vesting a Particular Token
mapping(address => Role) public roles;
//Mapping address of the wallet to the Role, which can be User, Partner, Team and stores it in roles
(array)

event VestingStarted(uint256 start);
event BeneficiaryAdded(address indexed beneficiary, Role role, uint256 amount);
event TokensReleased(address indexed beneficiary, uint256 amount);

constructor(address _token, uint256 _totalAllocatedTokens) Ownable(msg.sender) {
token = IERC20(_token);
totalAllocatedTokens = _totalAllocatedTokens;
}

function startVesting() external onlyOwner {
require(start == 0, "Vesting already started");
start = block.timestamp;
emit VestingStarted(start);
}

function addBeneficiary(address _beneficiary, Role _role, uint256 _amount) external onlyOwner {
require(start == 0, "Cannot add beneficiaries after vesting has started");
require(beneficiaries[_beneficiary].totalAmount == 0, "Beneficiary already added");

uint256 cliff;
uint256 duration;

if (_role == Role.User) {
require(_amount == totalAllocatedTokens.mul(50).div(100), "Invalid amount for User role");
cliff = 305 days;
duration = 730 days;
} else if (_role == Role.Partner) {
require(_amount == totalAllocatedTokens.mul(25).div(100), "Invalid amount for Partner role");
cliff = 60 days;
duration = 365 days;
} else if (_role == Role.Team) {
require(_amount == totalAllocatedTokens.mul(25).div(100), "Invalid amount for Team role");
cliff = 60 days;
duration = 365 days;
}

beneficiaries[_beneficiary] = VestingSchedule({
totalAmount: _amount,
cliff: cliff,
duration: duration,
released: 0
});
roles[_beneficiary] = _role;

emit BeneficiaryAdded(_beneficiary, _role, _amount);
}

function releaseTokens(address _beneficiary) external {
require(start != 0, "Vesting has not started");
VestingSchedule storage schedule = beneficiaries[_beneficiary];
require(schedule.totalAmount > 0, "No vesting schedule for beneficiary");

uint256 vestedAmount = _vestedAmount(schedule);
uint256 unreleased = vestedAmount.sub(schedule.released);

require(unreleased > 0, "No tokens to release");

schedule.released = schedule.released.add(unreleased);
token.transfer(_beneficiary, unreleased);

emit TokensReleased(_beneficiary, unreleased);
}

function _vestedAmount(VestingSchedule memory schedule) internal view returns (uint256) {
//block.timestamp: Significes the current time.
if (block.timestamp < start.add(schedule.cliff)) {
return 0;
} else if (block.timestamp >= start.add(schedule.duration)) {
return schedule.totalAmount;
} else {
return schedule.totalAmount.mul(block.timestamp.sub(start)).div(schedule.duration);
}
}

} 

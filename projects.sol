// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Medical Insurance System
 * @dev A smart contract to manage medical insurance claims transparently.
 */
contract MedicalInsurance {

    // --- Roles ---
    address public insurer; // The admin/insurance company

    // --- State Variables ---
    struct Claim {
        uint256 id;
        address patient;
        address doctor;
        string diagnosis;     // Encrypted hash or description
        uint256 amount;       // Amount claimed in Wei
        uint256 timestamp;
        ClaimStatus status;
        string rejectionReason; // Optional
    }

    enum ClaimStatus { Pending, Approved, Rejected }

    // Storage
    mapping(uint256 => Claim) public claims;
    mapping(address => bool) public authorizedDoctors;
    uint256 public claimCount;

    // --- Events ---
    // Emitted when a doctor submits a new claim
    event ClaimSubmitted(uint256 indexed claimId, address indexed patient, address indexed doctor, uint256 amount);
    // Emitted when the insurer processes a claim
    event ClaimProcessed(uint256 indexed claimId, ClaimStatus status, string reason);
    // Emitted when a doctor is authorized
    event DoctorAuthorized(address doctor);

    // --- Modifiers ---
    modifier onlyInsurer() {
        require(msg.sender == insurer, "Only the Insurer can perform this action");
        _;
    }

    modifier onlyAuthorizedDoctor() {
        require(authorizedDoctors[msg.sender], "Only authorized doctors can submit claims");
        _;
    }

    // --- Constructor ---
    constructor() {
        insurer = msg.sender; // The deployer is the insurance company
    }

    // --- Functions ---

    /**
     * @dev 1. Authorize a doctor/hospital to submit claims.
     * @param _doctor Address of the doctor/hospital wallet.
     */
    function authorizeDoctor(address _doctor) external onlyInsurer {
        authorizedDoctors[_doctor] = true;
        emit DoctorAuthorized(_doctor);
    }

    /**
     * @dev 2. Submit a new claim (Called by Doctor/Hospital).
     * @param _patient Address of the patient.
     * @param _diagnosis Diagnosis details or IPFS hash of the report.
     * @param _amount Cost of treatment (in Wei).
     */
    function submitClaim(address _patient, string memory _diagnosis, uint256 _amount) external onlyAuthorizedDoctor {
        claimCount++;
        
        claims[claimCount] = Claim({
            id: claimCount,
            patient: _patient,
            doctor: msg.sender,
            diagnosis: _diagnosis,
            amount: _amount,
            timestamp: block.timestamp,
            status: ClaimStatus.Pending,
            rejectionReason: ""
        });

        emit ClaimSubmitted(claimCount, _patient, msg.sender, _amount);
    }

    /**
     * @dev 3. Approve a claim (Called by Insurer).
     * In a real system, this might trigger a stablecoin transfer.
     */
    function approveClaim(uint256 _claimId) external onlyInsurer {
        require(claims[_claimId].id != 0, "Claim does not exist");
        require(claims[_claimId].status == ClaimStatus.Pending, "Claim is not pending");

        claims[_claimId].status = ClaimStatus.Approved;
        
        emit ClaimProcessed(_claimId, ClaimStatus.Approved, "Approved");
    }

    /**
     * @dev 4. Reject a claim with a reason (Called by Insurer).
     */
    function rejectClaim(uint256 _claimId, string memory _reason) external onlyInsurer {
        require(claims[_claimId].id != 0, "Claim does not exist");
        require(claims[_claimId].status == ClaimStatus.Pending, "Claim is not pending");

        claims[_claimId].status = ClaimStatus.Rejected;
        claims[_claimId].rejectionReason = _reason;

        emit ClaimProcessed(_claimId, ClaimStatus.Rejected, _reason);
    }

    // --- View Functions (For Frontend) ---

    /**
     * @dev Get details of a specific claim.
     */
    function getClaimDetails(uint256 _claimId) external view returns (Claim memory) {
        return claims[_claimId];
    }
}

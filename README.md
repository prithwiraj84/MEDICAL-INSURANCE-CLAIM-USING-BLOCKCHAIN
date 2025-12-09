# 🏥 Medical Insurance Claim Using Blockchain

A simple, transparent medical insurance claim management smart contract built on Ethereum-compatible blockchains using **Solidity 0.8.x**.

This contract lets:

- 🧑‍⚕️ Authorized doctors/hospitals submit claims on behalf of patients  
- 🛡️ Insurers review, approve, or reject claims  
- 🔍 Anyone read claim data on-chain for transparency

---

## ✨ Key Features

- **Role-based access control**
  - `insurer` (contract deployer) acts as the insurance company/admin
  - Only **authorized doctors** can submit claims
- **Transparent claim lifecycle**
  - Each claim has a unique `id`, `status`, `diagnosis`, `amount`, and timestamps
- **Claim status tracking**
  - `Pending`, `Approved`, `Rejected` via `ClaimStatus` enum
- **Event-driven architecture**
  - Frontends can listen to:
    - `ClaimSubmitted`
    - `ClaimProcessed`
    - `DoctorAuthorized`
- **Extensible design**
  - Easy to plug in payment logic (e.g., ERC20 stablecoins) in `approveClaim`

---

## 📦 Smart Contract Overview

### Contract: `MedicalInsurance`

#### Roles

- `insurer`  
  - Set in the constructor as `msg.sender` (deployer)
  - Can authorize doctors
  - Can approve/reject claims

- `authorizedDoctors` (`mapping(address => bool)`)  
  - Only addresses marked `true` can submit claims

---

### Data Structures

#### `struct Claim`

```solidity
struct Claim {
    uint256 id;
    address patient;
    address doctor;
    string diagnosis;
    uint256 amount;
    uint256 timestamp;
    ClaimStatus status;
    string rejectionReason;
}

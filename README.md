# Decentralized Crowdfunding Platform

A production-ready, secure, time-bound crowdfunding smart contract built using **Solidity** and the **Foundry** development framework. This platform allows users to safely launch funding campaigns, accept native ether (ETH) contributions, and handles automated risk mitigation via a pull-payment refund architecture.

## Core Features
- **Decentralized Campaigns:** Anyone can initialize a campaign by setting an explicit funding target, start time, and expiration window (up to 90 days).
- **Secure Financial Logic:** Uses the **Checks-Effects-Interactions** pattern to completely neutralize potential reentrancy attacks during refund loops.
- **Automated Risk Protection:** 
  - If a campaign meets its goal, only the designated creator can claim the funds.
  - If a campaign fails to hit its target by the deadline, contributors maintain sole custody to safely pull back their exact investments.

## Tech Stack & Architecture
- **Smart Contract Language:** Solidity ^0.8.20
- **Development & Testing Framework:** Foundry (Forge)
- **Security Paradigm:** Pull-over-Push payments, state isolation checks, time-lock guards.

## Getting Started

### Prerequisites
Make sure you have Foundry installed on your environment:
`curl -L https://foundry.paradigm.xyz | bash`
`foundryup`

### Installation & Compilation
Clone this repository to your local environment and compile the contracts:
`forge build`

### Running Unit Tests
Execute the automated validation suite to test state machines, time-warps, and edge-case behaviors:
`forge test`

/* global describe it before ethers */

const { ethers } = require('hardhat');
const { expect, assert } = require('chai')

const {
  getSelectors,
  FacetCutAction,
  removeSelectors,
  findAddressPositionInFacets
} = require('../scripts/libraries/diamond.js')

const { deployDiamond } = require('../scripts/deploy.js')

describe('DiamondTest', async function () {
  let diamondAddress = '0xD0Bca8aE397B440d3a085532Cc22FBa9F380a800'
  let diamondCutFacet
  let diamondLoupeFacet
  let ownershipFacet
  let approvalFacet
  let proposalFacet
  let ProposalFacetV2
  let proposalFacetV2
  let initializerFacet
  let result
  const addresses = []
  let approver1 = '0x98aa23D04fD37a1F743230fCa533bB2ae8451765'
  let approver2 = '0xd3EaC8916630161bBBD3c2ee75d89e0B2E08B831'
  let approver3 = '0xee903190c03414BE007eb9a8C1F70b70bA3650dE'
  let recipient = '0xd3EaC8916630161bBBD3c2ee75d89e0B2E08B831'
  let recipient2

  before(async function () {
    // const accounts = await ethers.getSigners()
    // approver1 = accounts[1];
    // approver2 = accounts[2];
    // recipient = accounts[3];
    // recipient2 = accounts[4];

    // diamondAddress = await deployDiamond()

    diamondCutFacet = await ethers.getContractAt('DiamondCutFacet', diamondAddress)
    diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)
    ownershipFacet = await ethers.getContractAt('OwnershipFacet', diamondAddress)

    initializerFacet = await ethers.getContractAt('InitializerFacet', diamondAddress)
    approvalFacet = await ethers.getContractAt('ApprovalFacet', diamondAddress)
    proposalFacet = await ethers.getContractAt('ProposalFacet', diamondAddress)

  })

  it('should have six facets -- call to facetAddresses function', async () => {
    for (const address of await diamondLoupeFacet.facetAddresses()) {
      addresses.push(address)
    }

    assert.equal(addresses.length, 6)
  })

  it('facets should have the right function selectors -- call to facetFunctionSelectors function', async () => {
    let selectors = getSelectors(diamondCutFacet)
    result = await diamondLoupeFacet.facetFunctionSelectors(addresses[0])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(diamondLoupeFacet)
    result = await diamondLoupeFacet.facetFunctionSelectors(addresses[1])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(ownershipFacet)
    result = await diamondLoupeFacet.facetFunctionSelectors(addresses[2])
    assert.sameMembers(result, selectors)
  })

  it('selectors should be associated to facets correctly -- multiple calls to facetAddress function', async () => {
    assert.equal(
      addresses[0],
      await diamondLoupeFacet.facetAddress('0x1f931c1c')
    )
    assert.equal(
      addresses[1],
      await diamondLoupeFacet.facetAddress('0xcdffacc6')
    )
    assert.equal(
      addresses[1],
      await diamondLoupeFacet.facetAddress('0x01ffc9a7')
    )
    assert.equal(
      addresses[2],
      await diamondLoupeFacet.facetAddress('0xf2fde38b')
    )
  })

  it('should InitializerFacet function call', async () => {
    const trx = await initializerFacet.initialize(1)
    trx.wait();
  })

  it('should ApprovalFacet addApprover function call', async () => {
    const trx = await approvalFacet.addApprover(approver1)
    trx.wait();
    console.log('Transaction hash:', trx.hash);
  })

    it('should ApprovalFacet getApprover function call', async () => {
      const isApprover = await approvalFacet.getApprover(approver1, { gasLimit: 10000000 });
      expect(isApprover).to.be.true;
  });

  it('should revert ApprovalFacet getApprover function call if approver does not exist', async () => {
    try {
      const isApprover = await approvalFacet.getApprover(approver2);
    } catch (err) {
      console.log('Error caught:', err.message);
    }
    await expect(approvalFacet.getApprover(approver2))
      .to.be.revertedWith('Approver does not exist');
  });


  it('should ApprovalFacet addApprover function call to add another approver', async () => {
    const trx = await approvalFacet.addApprover(approver3)
    trx.wait();
  })

  it('should revert ProposalFacet createProposal function call if approver not exist', async () => {
    await expect(proposalFacet.createProposal(recipient, 1))
      .to.be.revertedWith('Approver does not exist')
  })

  it('should deposit 0.1 ether into the contract using depositEther function', async function () {
    const approver1Signer = await ethers.getSigner(approver1);
    const proposalFacetAsApprover1 = proposalFacet.connect(approver1Signer);
    const depositAmount = ethers.utils.parseEther('0.1');
    const tx = await proposalFacetAsApprover1.depositEther({ value: depositAmount });
    await tx.wait();
    const contractBalance = await ethers.provider.getBalance(proposalFacet.address);
    console.log('Contract balance before execution', contractBalance.toString());
    expect(contractBalance).to.equal(depositAmount);
  });

  it('should ProposalFacet createProposal function call', async () => {
    const approver1Signer = await ethers.getSigner(approver1);
    const approvalFacetAsApprover1 = proposalFacet.connect(approver1Signer);
    const trx = await approvalFacetAsApprover1.createProposal(recipient, ethers.utils.parseEther('1'));
    await trx.wait();
  })

  it('should ProposalFacet approveProposal function call', async () => {
    const approvalFacetAsApprover1 = proposalFacet.connect(approver1);
    const approvalFacetAsApprover2 = proposalFacet.connect(approver2);
    const trx1 = await approvalFacetAsApprover1.approveProposal(1);
    const trx2 = await approvalFacetAsApprover2.approveProposal(1);
    await trx1.wait();
    await trx2.wait();
  })

  it('should get contract balance', async function () {
    const contractBalanceAfterExecution = await ethers.provider.getBalance(proposalFacet.address);
    console.log("Contract balance after execution:", contractBalanceAfterExecution.toString());
    const recipientBalanceAfter = await ethers.provider.getBalance(recipient);
    console.log("Recipient's balance after execution:", recipientBalanceAfter.toString());
  });

  it('should upgrade the ProposalFacet and remove old function selectors', async function () {
    ProposalFacetV2 = await ethers.getContractFactory('ProposalFacetV2');
    proposalFacetV2 = await ProposalFacetV2.deploy();
    await proposalFacetV2.deployed();
    console.log('New ProposalFacetV2 deployed at:', proposalFacetV2.address);

    const oldSelectors = getSelectors(proposalFacet);
    const newSelectors = getSelectors(proposalFacetV2);

    const cut = [];

    if (oldSelectors.length > 0) {
      cut.push({
        facetAddress: ethers.constants.AddressZero,
        action: FacetCutAction.Remove,
        functionSelectors: oldSelectors,
      });
    }

    if (newSelectors.length > 0) {
      cut.push({
        facetAddress: proposalFacetV2.address,
        action: FacetCutAction.Add,
        functionSelectors: newSelectors,
      });
    }

    const tx = await diamondCutFacet.diamondCut(cut, ethers.constants.AddressZero, '0x');
    const receipt = await tx.wait();
    expect(receipt.status).to.equal(1, 'Diamond cut failed');
    console.log('Diamond cut successful, ProposalFacet upgraded, old functions removed.');
  });

  it('should revert to call old ProposalFacet createProposal function', async () => {
    const proposalFacetAsApprover1 = proposalFacet.connect(approver1);
    await expect(proposalFacetAsApprover1.createProposal(recipient, ethers.utils.parseEther('1')))
      .to.be.reverted;
  });

  it('should successfully call ProposalFacetV2 createProposal with new parameter', async () => {
    const proposalFacetV2 = await ethers.getContractAt('ProposalFacetV2', diamondAddress);
    const proposalFacetV2ConnectedAsApprover1 = proposalFacetV2.connect(approver1);
    const trx = await proposalFacetV2ConnectedAsApprover1.createProposal(
      recipient2.address,
      ethers.utils.parseEther('1'),
      "Test Proposal Name"
    );
    await trx.wait();
  });

  it('should return proposal 1', async () => {
    const proposalFacetV2 = await ethers.getContractAt('ProposalFacetV2', diamondAddress);
    const proposalDetails = await proposalFacetV2.getProposal(1);
    expect(proposalDetails.proposalId.toString()).to.equal('1', 'Proposal ID should be 1');
    expect(proposalDetails.recipient).to.equal(recipient, 'Recipient address mismatch');
    expect(ethers.utils.formatEther(proposalDetails.amount)).to.equal('1.0', 'Amount mismatch');
    expect(proposalDetails.approvals.toString()).to.equal('2', 'Approvals count should be 0 initially');
    expect(proposalDetails.executed).to.be.true;
  });


  it('should return proposal 2', async () => {
    const proposalFacetV2 = await ethers.getContractAt('ProposalFacetV2', diamondAddress);
    const proposalDetails = await proposalFacetV2.getProposal(2);
    expect(proposalDetails.proposalId.toString()).to.equal('2', 'Proposal ID should be 1');
    expect(proposalDetails.recipient).to.equal(recipient2.address, 'Recipient address mismatch');
    expect(ethers.utils.formatEther(proposalDetails.amount)).to.equal('1.0', 'Amount mismatch');
    expect(proposalDetails.approvals.toString()).to.equal('0', 'Approvals count should be 0 initially');
    expect(proposalDetails.executed).to.be.false;
  });
})

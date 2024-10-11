const { ethers } = require('hardhat');
const { getSelectors, FacetCutAction } = require('./libraries/diamond.js');

async function upgradeProposalFacet(diamondAddress) {
    const ProposalFacet = await ethers.getContractFactory('ProposalFacetV2');
    const proposalFacet = await ProposalFacet.deploy();
    await proposalFacet.deployed();
    console.log('Upgraded ProposalFacet deployed at:', proposalFacet.address);

    const diamondCutFacet = await ethers.getContractAt('IDiamondCut', diamondAddress);

    // Get the function selectors for the new ProposalFacet
    const newSelectors = getSelectors(proposalFacet);

    // Prepare the diamond cut
    const cut = [{
        facetAddress: proposalFacet.address,
        action: FacetCutAction.Replace,
        functionSelectors: newSelectors
    }];

    // Perform the diamond cut to upgrade the facet
    const tx = await diamondCutFacet.diamondCut(cut, ethers.constants.AddressZero, '0x');
    console.log('Diamond cut tx: ', tx.hash);
    const receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`);
    }
    console.log('Diamond cut completed successfully');

}

if (require.main === module) {
    upgradeProposalFacet(diamondAddress)
        .then(() => process.exit(0))
        .catch(error => {
            console.error(error);
            process.exit(1);
        });
}

exports.upgradeProposalFacet = upgradeProposalFacet;

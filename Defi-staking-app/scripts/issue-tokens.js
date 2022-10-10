const DecentralBank = artifacts.require('DecentralBank');

module.exports = async function issueRewards(callback) {
    let decentralbank = await DecentralBank.deployed()
    await DecentralBank.issueTokens()
    console.log('Tokens have been issued successfully!')
    callback()
};
const { assert } = require('console')

const Tether = artifacts.require('Tether')
const RWD = artifacts.require('RWD')
const DecentralBank = artifacts.require('DecentralBank')

require('chai')
.use(require('chai-as-promised'))
.should()

contract('DecentralBank', ([[owner, customer]]) => {

    let tether, rwd, decentralBank

    function tokens(number) {
        return web3.utils.toWei(number, 'ether')
    }

    before(async () => {
        // Load contracts
        tether = await Tether.new()
        rwd = await RWD.new()
        decentralBank = await DecentralBank.new(rwd.address, tether.address)

        // 
        await rwd.transfer(decentralBank.address, tokens('1000000'))

        // Transfer 100 poke Tethers to customers
        await tether.transfer(customer, tokens('100'), {from: owner})
    })

    describe('Poke Tether  Deployment', async () => {
        it('matches name sucessfully', async () => {
            const name = await tether.name()
            assert.equal(name, 'Poke Tether Token')
        })
    })

    describe('Reward Token Deployment', async () => {
        it('matches name successfully', async () => {
            const name = await rwd.name()
            assert.equal(name, 'Reward Token')
        })
    })

    describe('Decentral Bank Deployment', async () => {
        it('matches name successfully', async () => {
            const name = await decentralBank.name()
            assert.equal(name, 'Decentral Bank')
        })

        it('contract has tokens', async () =>{
            let balance = await rwd.balanceOf(decentralBank.address)
            assert.equal(balance, tokens('1000000'))
        })
    })

    describe('Yeild Farming, async', async () => {
        it('reward tokens for staking', async () => {
           let result 
           // Check Investor Balance
           result = await tether.balanceOf(customer)
           assert.equal(result.toString(), tokens('100'), 'Customer Poke Wallet Balance before staking')

           // Check staking for customer
           await tether.approve(decentralBank.address, tokens('100'), {from: customer})
           await decentralBank.depositTokens(tokens('100'), {from: customer})

           // Check customer balance
           result = await tether.balanceOf(customer)
           assert.equal(result.toString(), tokens('0'), 'Customer Poke Wallet Balance after staking 100 tokens')

           // Check Balance of the decentral Bank
           result = await tether.balanceOf(decentralBank.address)
           assert.equal(result.toString(), tokens('100'), 'Decentral Bank Poke Wallet Balance after staking from customer')

           // Check Is Staking update
           result = await decentralBank.isStaking(customer)
           assert.equal(result.toString(), 'true', 'Customer is staking status after staking from customer')

           // Issue Tokens
           await decentralBank.issueTokens({from: owner})

           // Ensure only the owner can Issue Tokens
           await decentralBank.issueTokens({from: customer}).should.be.rejected;

           // Unstake tokens
           await decentralBank.unstakeTokens({from: customer})



           // Check unstaking balances
        
           result = await tether.balanceOf(customer)
           assert.equal(result.toString(), tokens('100'), 'Customer Poke Wallet Balance after unstaking')
        
           // Check updated Balance of the decentral Bank
           result = await tether.balanceOf(decentralBank.address)
           assert.equal(result.toString(), tokens('0'), 'Decentral Bank Poke Wallet Balance after staking from customer')
        
           // Is Staking update
           result = await decentralBank.isStaking(customer)
           assert.equal(result.toString(), 'false', 'Customer is no longer staking after unstaking')
        })
    })
})
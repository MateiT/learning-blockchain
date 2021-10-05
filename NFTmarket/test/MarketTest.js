const Market = artifacts.require("Market");
const MarketToken = artifacts.require("MarketToken");

function toWei(nr){
  return nr * 1000000000000000000;
}

contract("Market", accounts => {
  let [alice, bob] = accounts;
  let contractInstance;
  let tokenInstance;
  beforeEach(async () => {
    contractInstance = await Market.new();
    tokenInstance = await MarketToken.new();
  });

  it("should be able to return the corect listing creation price", async () => {
    const result = await contractInstance.listingCreationPrice({from: alice});
    assert.equal(result.words[result.length-1], 1);
  })
  it("should be able to return the corect purchase fee", async () => {
    const result = await contractInstance.listingPurchaseFee({from: alice});
    assert.equal(result.words[result.length-1], 2);
    
    
  })
  it("should mint 10 new tokens to msg.sender", async () => {
    const resultBefore = await tokenInstance.balanceOf(alice,{from: alice});
    assert.equal(resultBefore.words[resultBefore.length-1], 0);
    const result = await tokenInstance.mintToMsgSender(contractInstance.address, {from: alice});
    assert.equal(result.receipt.status, true);
    const resultAfter = await tokenInstance.balanceOf(alice,{from: alice});
    assert.equal(resultAfter.words[resultAfter.length-1], 10);
  })
  it("should be able to create a new listing", async () => {
    await tokenInstance.mintToMsgSender(contractInstance.address, {from: alice});
    tokenId = 0;
    tokenPrice = toWei(0.00001); 
    expectedPay = (tokenPrice * 1) / 100;
    const result = await contractInstance.createListing(tokenInstance.address,tokenId,tokenPrice,{from: alice, value: expectedPay+1});
    assert.equal(result.receipt.status, true);
    assert.equal(result.logs[0].args._token.words[0],0);
    const result2 = await contractInstance.createListing(tokenInstance.address,tokenId+1,tokenPrice,{from: alice, value: expectedPay+1});
    assert.equal(result2.receipt.status, true);
  })
  
  it("should be able to return all active listings", async () => {
    await tokenInstance.mintToMsgSender(contractInstance.address, {from: alice});
    tokenId = 0;
    tokenPrice = toWei(0.00001); 
    expectedPay = (tokenPrice * 1) / 100;
    await contractInstance.createListing(tokenInstance.address,tokenId,tokenPrice,{from: alice, value: expectedPay+1});
    await contractInstance.createListing(tokenInstance.address,tokenId+1,tokenPrice,{from: alice, value: expectedPay+1});
    await contractInstance.createListing(tokenInstance.address,tokenId+2,tokenPrice,{from: alice, value: expectedPay+1});
    const result = await contractInstance.activeListings({from: alice});
    assert.equal(result.length, 3);
  })

  it("should cancel a listing", async () => {
    await tokenInstance.mintToMsgSender(contractInstance.address, {from: alice});
    tokenId = 0;
    tokenPrice = toWei(0.00001); 
    expectedPay = (tokenPrice * 1) / 100;
    await contractInstance.createListing(tokenInstance.address,tokenId,tokenPrice,{from: alice, value: expectedPay+1});
    await contractInstance.createListing(tokenInstance.address,tokenId+1,tokenPrice,{from: alice, value: expectedPay+1});
    await contractInstance.createListing(tokenInstance.address,tokenId+2,tokenPrice,{from: alice, value: expectedPay+1});
    await contractInstance.cancelListing(0,{from: alice});
    const result = await contractInstance.activeListings({from: alice});
    const firstListing = await contractInstance.listings.call(0);
    assert.equal(firstListing.status.words[0], 0);
  })

  it("should return the corect listing", async () => {
    await tokenInstance.mintToMsgSender(contractInstance.address, {from: alice});
    tokenId = 0;
    tokenPrice = toWei(0.00001); 
    expectedPay = (tokenPrice * 1) / 100;
    await contractInstance.createListing(tokenInstance.address,tokenId,tokenPrice,{from: alice, value: expectedPay+1});
    await contractInstance.createListing(tokenInstance.address,tokenId+1,tokenPrice,{from: alice, value: expectedPay+1});
    await contractInstance.createListing(tokenInstance.address,tokenId+2,tokenPrice,{from: alice, value: expectedPay+1});
    await contractInstance.cancelListing(0,{from: alice});
    const result = await contractInstance.getListing(1,{from: alice});
    assert.equal(result.token, 1);
  })

  it("should be able to buy a listing", async () => {
    await tokenInstance.mintToMsgSender(contractInstance.address, {from: alice});
    tokenId = 0;
    tokenPrice = toWei(0.00001); 
    expectedPay = (tokenPrice * 1) / 100;
    await contractInstance.createListing(tokenInstance.address,tokenId,tokenPrice,{from: alice, value: expectedPay+1});
    await contractInstance.createListing(tokenInstance.address,tokenId+1,tokenPrice,{from: alice, value: expectedPay+1});
    await contractInstance.createListing(tokenInstance.address,tokenId+2,tokenPrice,{from: alice, value: expectedPay+1});
    await contractInstance.purchase(0,{from: bob, value: tokenPrice});

    const result = await contractInstance.activeListings({from: alice});
    const firstListing = await contractInstance.listings.call(0);
    assert.equal(firstListing.status.words[0], 2);
  })
  
});
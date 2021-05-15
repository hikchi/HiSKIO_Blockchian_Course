const Bank = artifacts.require("./Erc20Bank.sol"); // 目標合約的 bytecode

contract("Erc20Bank", (accounts) => {
    let bankContract;
    let owner = accounts[0];
    let notOwnerA = accounts[1];
    
    before(async () => { // 在第一個測試開始前執行一次, 其他還有 after, beforceEach ...
        bankContract = await Bank.deployed(); // 部署全新合約到鏈上，並用變數記錄起來
    });
    // 測試 owner 鑄造錢幣給自己
    it("Test owner mint coins to owner with amount 7414", async () => {
        await bankContract.mint(owner, 7414, {from: owner}); // {} 用於標明 msg.sender, msg.value 等
        let coinsValue = await bankContract.balanceOf(owner);
        assert.equal(coinsValue, 7414, 'coin value Not Equal');
    });
    // 測試 owner 鑄造錢幣給 notOwnerA
    it("Test owner mint coins to notOwnerA with amount 777", async () => {
        await bankContract.mint(notOwnerA, 777, {from: owner});
        let coinsValue = await bankContract.balanceOf(notOwnerA);
        assert.equal(coinsValue, 777, 'coin value Not Equal');
    });
    // 測試 notOwnerA 鑄造錢幣，預期失敗
    it("Test notOwnerA coin minting failed", async () => {
        try {
            await bankContract.mint(notOwnerA, 0130,  {from: notOwnerA});
            assert.fail("The transaction should have thrown an error"); // 不該執行到這
        }catch (err) {
            assert.include(err.message, "revert", "The error message should contain 'revert'");
        }
    });

    // 測試approve
    it("Test Approving", async () => {
        await bankContract.approve(notOwnerA, 1000, {from: owner});
        const allowance = await bankContract.allowance(owner, notOwnerA);
        assert.equal(allowance, 1000, "wrong allowance")
    })
    // 測試transfer
    it("Test Transfering", async () => {
        await bankContract.transfer(notOwnerA, 10, {from: owner});
        const balanceOfNotOwnerA = await bankContract.balanceOf(notOwnerA);
        assert.equal(balanceOfNotOwnerA, 787, "wrong balance of A")
    })
    // 測試transferFrom
    it("Test Transfering From", async () => {
        await bankContract.transferFrom(owner, accounts[2], 10, {from: notOwnerA});
        const balanceOfAccount2 = await bankContract.balanceOf(accounts[2]);
        assert.equal(balanceOfAccount2, 10, "wrong balance of account2")
    })

});



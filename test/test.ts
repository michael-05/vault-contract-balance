import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("VaultContract", function () {
    async function deployContractsFixture() {
        const [owner, account1, account2, account3] = await ethers.getSigners();

        const VaultContract = await ethers.getContractFactory("VaultContract");
        const vaultContract = await VaultContract.deploy();

        const MyToken = await ethers.getContractFactory("MyToken");
        const myToken = await MyToken.deploy();

        // Transfer 100 tokens from owner to account1, account2, account3
        await myToken.transfer(account1.address, 100);
        await myToken.transfer(account2.address, 100);
        await myToken.transfer(account3.address, 100);

        expect(await myToken.balanceOf(account1.address)).to.equal(100);
        expect(await myToken.balanceOf(account2.address)).to.equal(100);
        expect(await myToken.balanceOf(account3.address)).to.equal(100);

        return { vaultContract, myToken, account1, account2, account3 };
    }

    describe("Deposit & Withdraw", function () {
        it("should find account2 and account3", async function () {
            const { vaultContract, myToken, account1, account2, account3 } = await loadFixture(deployContractsFixture);
            const tokenAddress = myToken.address;


            // account1 approve 10 tokens to vault
            // expect token allowance of account1 to vault to be 10
            // account1 deposits 10 tokens to vault
            // expect token balance of account1 to be 90
            // expect token balance of vault to be 10
            await myToken.connect(account1).approve(vaultContract.address, 10);
            expect(await myToken.allowance(account1.address, vaultContract.address)).to.equal(10);
            await vaultContract.connect(account1).deposit(tokenAddress, 10);
            expect(await myToken.balanceOf(account1.address)).to.equal(90);
            expect(await myToken.balanceOf(vaultContract.address)).to.equal(10);


            // account2 approve 20 tokens to vault
            // expect token allowance of account2 to vault to be 20
            // account2 deposits 20 tokens to vault
            // expect token balance of account2 to be 80
            // expect token balance of vault to be 10 + 20 = 30
            await myToken.connect(account2).approve(vaultContract.address, 20);
            expect(await myToken.allowance(account2.address, vaultContract.address)).to.equal(20);
            await vaultContract.connect(account2).deposit(tokenAddress, 20);
            expect(await myToken.balanceOf(account2.address)).to.equal(80);
            expect(await myToken.balanceOf(vaultContract.address)).to.equal(30);


            // account3 approve 30 tokens to vault
            // expect token allowance of account3 to vault to be 30
            // account3 deposits 30 tokens to vault
            // expect token balance of account3 to be 70
            // expect token balance of vault to be 30 + 30 = 60
            await myToken.connect(account3).approve(vaultContract.address, 30);
            expect(await myToken.allowance(account3.address, vaultContract.address)).to.equal(30);
            await vaultContract.connect(account3).deposit(tokenAddress, 30);
            expect(await myToken.balanceOf(account3.address)).to.equal(70);
            expect(await myToken.balanceOf(vaultContract.address)).to.equal(60);


            // expect two wealthies are account2 and account3
            const [top1Address, top1Amount, top2Address, top2Amount] = await vaultContract.twoWealthies(tokenAddress);
            expect(top1Address).to.equal(account3.address);
            expect(top1Amount).to.equal(await vaultContract.vault(tokenAddress, account3.address));
            expect(top2Address).to.equal(account2.address);
            expect(top2Amount).to.equal(await vaultContract.vault(tokenAddress, account2.address));


            // account1 withdraw from vault
            // expect token balance of account1 to be 100
            // expect token balance of vault to be 60 - 10 = 50
            await vaultContract.connect(account1).withdraw(tokenAddress);
            expect(await myToken.balanceOf(account1.address)).to.equal(100);
            expect(await myToken.balanceOf(vaultContract.address)).to.equal(50);


            // account2 withdraw from vault
            // expect token balance of account2 to be 100
            // expect token balance of vault to be 50 - 20 = 30
            await vaultContract.connect(account2).withdraw(tokenAddress);
            expect(await myToken.balanceOf(account2.address)).to.equal(100);
            expect(await myToken.balanceOf(vaultContract.address)).to.equal(30);


            // account3 withdraw from vault
            // expect token balance of account3 to be 100
            // expect token balance of vault to be 30 - 30 = 0
            await vaultContract.connect(account3).withdraw(tokenAddress);
            expect(await myToken.balanceOf(account3.address)).to.equal(100);
            expect(await myToken.balanceOf(vaultContract.address)).to.equal(0);
        });
    });
});

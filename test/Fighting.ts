import { ethers } from "hardhat";
import chai from "chai";
import { expect, use, assert } from "chai";
import chaiAsPromised from "chai-as-promised";
import { Fighting, Fighting__factory } from "../typechain-types";
import BN from "bn.js";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Provider } from "@ethersproject/abstract-provider";
// import { console } from "chai";

// chai.use(solidity);
use(chaiAsPromised);
chai.should();

const constants = {
  ZERO_ADDRESS: "0x0000000000000000000000000000000000000000",
};

describe("Fighting", async () => {
  // const Fight = await ethers.getContractFactory("Fighting");
  let fighting: Fighting;
  let Fighting: Fighting__factory;
  let accounts: SignerWithAddress[];
  let deployer: SignerWithAddress;
  let user1: SignerWithAddress;
  let user2: SignerWithAddress;
  let user3: SignerWithAddress;
  let user4: SignerWithAddress;

  before(async () => {
    Fighting = await ethers.getContractFactory("Fighting");
    accounts = await ethers.getSigners();
    deployer = accounts[0];
    user1 = accounts[1];
    user2 = accounts[2];
    user3 = accounts[3];
    user4 = accounts[4];
  });

  beforeEach(async () => {
    fighting = await Fighting.deploy();
    await fighting.deployed();
    await fighting.approvedForTransactions(user1.address);
    await fighting.approvedForTransactions(deployer.address);
    await fighting.approvedForTransactions(user3.address);
    await fighting.approvedForTransactions(user4.address);
  });

  describe("should start the contact with the name and symbol correct", async () => {
    it("Should return the name of the contract", async function () {
      console.log(await fighting.name());
      expect(fighting.name()).to.eventually.be.equal("PokemonNFT");
    });
    it("should not return a wrong name of the token", async () => {
      expect(fighting.name()).to.eventually.not.be.equal("YallaContract!!!");
    });

    it("Should return the symbol of the token", async function () {
      expect(fighting.symbol()).to.eventually.be.equal("PokNFT");
    });
    it("Should not return a wrong symbol of the token", async function () {
      expect(fighting.symbol()).to.eventually.not.be.equal("BBN");
    });
  });

  describe("approve ability to mint", function () {
    it("owner should be able to approve", async function () {
      await fighting.approvedForTransactions(user1.address, {
        from: deployer.address,
      });
      await fighting.approvedForTransactions(deployer.address, {
        from: deployer.address,
      });
      expect(fighting.approvedOrNot(deployer.address)).to.eventually.be.equal(
        true
      );
      expect(fighting.approvedOrNot(user1.address)).to.eventually.be.equal(
        true
      );
    });
  });

  describe("should return error when approve is done by not owner", function () {
    it("should return error when the msg.sender is not deployer", async function () {
      await expect(
        fighting.connect(user1).approvedForTransactions(user2.address)
      ).to.be.eventually.rejectedWith(
        Error,
        "Ownable: caller is not the owner"
      );
    });
  });
  describe("see if a pokemon is able to be minted", function () {
    it("should check if  pokemon is minted", async function () {
      await fighting.approvedForTransactions(user1.address, {
        from: deployer.address,
      });
      await fighting.connect(user1).mintPokemon("name", 16, 0, 0, 3, {
        value: ethers.utils.parseEther("0.033"),
      });
      let user1Add = user1.address;
      await expect(fighting.connect(user1).ownerOf(0)).to.be.eventually.equal(
        user1Add
      );
      await expect(fighting.connect(user1).ownerOf(0)).to.be.eventually.equal(
        user1.address
      );
    });
  });
  describe("reject with insufficient funds", function () {
    it("should reject with insufficient funds", async function () {
      await fighting.approvedForTransactions(deployer.address, {
        from: deployer.address,
      });
      await expect(
        fighting.connect(deployer).mintPokemon("last", 17, 1, 1, 4, {
          value: ethers.utils.parseEther("0.033"),
        })
      ).to.be.eventually.rejectedWith(Error, "insufficient funds!!");
    });
  });
  describe("It should mint pokemon", function () {
    it("should mint", async function () {
      await fighting.approvedForTransactions(user1.address);
      await fighting.approvedForTransactions(deployer.address);
      await fighting.approvedForTransactions(user3.address);
      await fighting.connect(user1).mintPokemon("name", 16, 0, 0, 3, {
        value: ethers.utils.parseEther("0.033"),
      });
      await fighting.connect(user3).mintPokemon("first", 18, 1, 2, 4, {
        value: ethers.utils.parseEther("0.044"),
      });
    });
  });
  describe("should send and accept challenge to fight", function () {
    it("should go through with the functions with no problem", async function () {
      await fighting.connect(user1).mintPokemon("name", 16, 0, 0, 3, {
        value: ethers.utils.parseEther("0.033"),
      });
      await fighting.connect(user3).mintPokemon("first", 18, 1, 2, 4, {
        value: ethers.utils.parseEther("0.044"),
      });
      await fighting.connect(user3).challenge(1, 0);
      await fighting.connect(user1).acceptChallenge(0, 1);
    });
  });
  describe("should burn pokemon after minting", function () {
    it("should burn pokemon after minting with no problem", async function () {
      await fighting.connect(user1).mintPokemon("name", 16, 0, 0, 3, {
        value: ethers.utils.parseEther("0.033"),
      });
      await fighting.connect(user1).sendBackPokemon(0);
    });
  });

  describe("should reject with burning pokemon saying this isn't your pokemon", function () {
    it("should reject with this isn't your pokemon to burn", async function () {
      await fighting.connect(user1).mintPokemon("name", 16, 0, 0, 3, {
        value: ethers.utils.parseEther("0.033"),
      });
      await expect(
        fighting.connect(user2).sendBackPokemon(0)
      ).to.be.eventually.rejectedWith(Error, "You do not own this Pokemon!!");
    });
  });
  describe("Should reject minting pokemon with more strength than 10", function () {
    it("should reject making a poke with more than 10 strength", async function () {
      await expect(
        fighting.connect(user1).mintPokemon("name", 16, 0, 0, 10, {
          value: ethers.utils.parseEther("0.11"),
        })
      ).to.be.eventually.rejectedWith(Error, "max strength allowed is 10");
    });
  });
  describe("reject cancel challenger", function () {
    it("should reject all cases", async function () {
      await fighting.connect(user1).mintPokemon("name", 16, 0, 0, 3, {
        value: ethers.utils.parseEther("0.033"),
      });
      await fighting.connect(user3).mintPokemon("first", 18, 1, 2, 4, {
        value: ethers.utils.parseEther("0.044"),
      });
      await expect(
        fighting.connect(user3).cancelChallenge(1, 0)
      ).to.be.eventually.rejectedWith(Error, "You have not initiated a fight");
      await fighting.connect(user3).challenge(1, 0);
      await expect(
        fighting.connect(user2).cancelChallenge(0, 1)
      ).to.be.eventually.rejectedWith(Error, "You can not cancel this fight");
      await fighting.connect(user1).acceptChallenge(0, 1);
      await expect(
        fighting.connect(user3).cancelChallenge(1, 0)
      ).to.be.eventually.rejectedWith(Error, "The battle already happened!!");
    });
  });
  describe("reject accept challenge", function () {
    it("should reject all cases", async function () {
      await fighting.connect(user1).mintPokemon("name", 16, 0, 0, 3, {
        value: ethers.utils.parseEther("0.033"),
      });
      await fighting.connect(user4).mintPokemon("second", 18, 1, 2, 6, {
        value: ethers.utils.parseEther("0.066"),
      });
      await fighting.connect(user3).mintPokemon("first", 18, 1, 2, 4, {
        value: ethers.utils.parseEther("0.044"),
      });
      await expect(
        fighting.connect(user1).acceptChallenge(0, 1)
      ).to.be.eventually.rejectedWith(
        Error,
        "not been invited to a challenge!"
      );
      await fighting.connect(user1).challenge(0, 1);
      await expect(
        fighting.connect(user3).acceptChallenge(1, 0)
      ).to.be.eventually.rejectedWith(Error, "You are not the owner");
    });
  });
});

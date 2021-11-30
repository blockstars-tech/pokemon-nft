// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./PokemonNFT.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract CreatePokemon is PokemonNFT {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenID;
  uint256 internal randNumber = 0;
  uint256 public increasePowerFee = 0.011 ether;
  uint256 public ownerCut = 0.001 ether;
  mapping(uint256 => uint256) internal pokemonworth;
  mapping(address => uint256) internal ownedPokemonCount;
  mapping(uint256 => address) internal ownerOfPokemon;
  mapping(uint256 => bool) internal mintedPokemon;

  struct Pokemon {
    string name;
    uint256 age;
    Sex sex;
    Colors color;
    uint256 strength;
    uint256 creationTime;
    uint32 readyTime;
    uint16 winCount;
    uint16 lossCount;
    uint16 currentLossCount;
  }

  enum Sex {
    male,
    female
  }

  enum Colors {
    red,
    blue,
    green,
    yellow,
    white,
    black,
    violet
  }

  Pokemon[] public pokemons;

  event NewPokemon(
    uint256 _tokenIds,
    string name,
    uint256 _age,
    Sex _sex,
    Colors color,
    uint256 strength
  );

  function mintPokemon(
    string memory _name,
    uint256 _age,
    Sex _sex,
    Colors _color,
    uint256 _amount
  ) public payable approvedForTrans returns (uint256 _id) {
    _id = _tokenID.current();
    require(ownerOfPokemon[_id] == address(0), "This Pokemon is already minted!");
    uint256 totalAmount = _amount * increasePowerFee;
    require(msg.value >= totalAmount, "insufficient funds!!");
    uint256 ownerTax = _amount * ownerCut;
    require(_amount < 10, "max strength allowed is 10");
    require(msg.value >= totalAmount, "insufficient funds!!");
    address payable owner;
    owner.transfer(ownerTax);
    uint256 _strength = 1 + _amount;
    pokemonworth[_id] += _amount;
    pokemons.push(Pokemon(_name, _age, _sex, _color, _strength, block.timestamp, 0, 0, 0, 0));
    ownerOfPokemon[_id] = msg.sender;
    ownedPokemonCount[msg.sender]++;
    mintedPokemon[_id] = true;
    tokenURI(_id);
    emit NewPokemon(_id, _name, _age, _sex, _color, _strength);
    _safeMint(msg.sender, _tokenID.current());
    _tokenID.increment();
  }

  function sendBackPokemon(uint256 _id) public {
    require(ownerOfPokemon[_id] == msg.sender, "You do not own this Pokemon!!");
    ownerOfPokemon[_id] = address(this);
    if (pokemonworth[_id] != 0) {
      uint256 amounts = pokemonworth[_id] * 0.01 ether;
      ownedPokemonCount[msg.sender]--;
      payable(msg.sender).transfer(amounts);
    }
    _beforeTokenTransfer(msg.sender, address(0), _id);
  }
}

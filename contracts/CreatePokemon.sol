// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./PokemonNFT.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract CreatePokemon is PokemonNFT {
  using Counters for Counters.Counter;
  using SafeMath for uint256;
  Counters.Counter private _tokenID;
  using SafeMath for uint256;
  uint256 internal randNumber = 0;
  uint256 public increasePowerFee = 0.011 ether;
  uint256 public ownerCut = 0.001 ether;

  function mintPokemon(
    string memory _name,
    uint256 _age,
    Sex _sex,
    Colors _color,
    uint256 _amount
  )
    public
    payable
    // uint256 _strength
    approvedForTrans
    returns (uint256 _id)
  {
    _id = _tokenID.current();
    require(
      ownerOfPokemon[_id] == address(0),
      "This Pokemon is already minted!"
    );
    uint256 totalAmount = _amount * increasePowerFee;
    require(msg.value >= totalAmount, "insufficient funds!!");
    uint256 ownerTax = _amount * ownerCut;
    require(_amount < 10, "max strength allowed is 10");
    require(msg.value >= totalAmount, "insufficient funds!!");
    address payable owner;
    owner.transfer(ownerTax);
    uint256 _strength = 1 + _amount;
    pokemonworth[_id] += _amount;
    creationTimestamp = block.timestamp;
    // comment out the creation timestamp?
    pokemons.push(
      Pokemon(
        _name,
        _age,
        _sex,
        _color,
        _strength,
        creationTimestamp,
        0,
        0,
        0,
        0
      )
    );
    ownerOfPokemon[_id] = msg.sender;
    ownedPokemonCount[msg.sender]++;
    mintedPokemon[_id] = true;
    emit NewPokemon(_id, _name, _age, _sex, _color, _strength);
    _safeMint(msg.sender, _tokenID.current());
    _tokenID.increment();
  }

  function sendBackPokemon(uint256 _id) public {
    require(ownerOfPokemon[_id] == msg.sender, "You do not own this Pokemon!!");
    ownerOfPokemon[_id] = address(this);
    if (pokemonworth[_id] != 0) {
      uint256 amounts = pokemonworth[_id] * 0.01 ether;
      payable(msg.sender).transfer(amounts);
      // (bool sent, ) = msg.sender.call{ value: amounts }("");
      // removed bytes memory data from second part of the above parameter
      // require(sent, "Failed to send ether");
    }
    _beforeTokenTransfer(msg.sender, address(0), _id);
  }
}

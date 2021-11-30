// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// uint256 _tokenID;
// uint256 creationTimestamp;

// function randStrength(uint256 _mod) internal returns (uint256) {
//   randNumber = randNumber.add(1);
//   return
//     uint256(
//       keccak256(abi.encodePacked(block.timestamp, msg.sender, randNumber))
//     ) % _mod;
// }

// function increaseStrength(uint256 _Id, uint256 _amount) public payable {
//   require(MintedPokemon[_Id], "There is no such pokemon");
//   require(
//     ownerOfPokemon[_Id] == msg.sender,
//     "You are not the owner of this pokemon!!"
//   );
//   uint256 totalAmount = _amount * increasePowerFee;
//   require(msg.value >= totalAmount, "insufficient funds!!");
//   uint256 ownerTax = _amount * ownerCut;
//   address payable owner;
//   owner.transfer(ownerTax);
//   // require(sent, "Failed to send Ether");
//   pokemonworth[_Id] += _amount;
//   // pokemons(Pokemon[_Id]._strength += _amount;
//   pokemons[_Id].strength.add(_amount);
// }

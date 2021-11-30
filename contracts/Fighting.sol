// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./CreatePokemon.sol";

contract Fighting is CreatePokemon {
  mapping(uint256 => bool) internal waitingForFight;
  mapping(uint256 => bool) internal waitingForResponse;
  mapping(uint256 => bool) internal sentAResponse;
  mapping(uint256 => RequestToFight) internal requestId;
  mapping(uint256 => bool) internal acceptedRequest;
  uint256 public winnerPokemon;
  uint256 public loserPokemon;
  uint256 public randNum = 0;
  uint256 public cooldownTime = 1 days;
  uint256 private _num = 0;
  uint256 private _battlenumber = 0;
  uint256 private currentNumber;
  uint256 private numbss;

  struct RequestToFight {
    uint256 pokemonAID;
    uint256 pokemonBID;
    uint256 timestampOfRequest;
  }

  RequestToFight[] public requestsToFights;

  event BattleHappened(
    uint256 pokemonAID,
    uint256 pokemonBID,
    uint256 battleNumber,
    uint256 timeStamp,
    uint256 winnerOfBattle
  );

  event NumberofFight(uint256 num);

  event RequestToFightz(uint256 pokemonAId, uint256 pokemonBId, uint256 timestampOfRequest);

  function randMod(uint256 _modulus) internal returns (uint256) {
    randNum = randNum++;
    return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNum))) % _modulus;
  }

  function challenge(uint256 pokeA, uint256 pokeb) public {
    require(ownerOfPokemon[pokeA] == msg.sender, "You can't initiate the fight");
    require(mintedPokemon[pokeA], "Pokemon not ready to fight");
    require(mintedPokemon[pokeb], "Enemy Pokemon not ready to fight");
    require(!waitingForFight[pokeA], "You are on hold");
    require(!waitingForFight[pokeb], "The opponent is on hold");
    waitingForResponse[pokeb] = true;
    _num = currentNumber;
    if (pokemons[pokeA].currentLossCount == 2) {
      battleReady(pokeA);
    }
    if (pokemons[pokeb].currentLossCount == 2) {
      battleReady(pokeb);
    }
    requestsToFights.push(RequestToFight(pokeA, pokeb, block.timestamp));
    requestId[currentNumber] = RequestToFight(pokeA, pokeb, block.timestamp);
    sentAResponse[pokeA] = true;
    _num++;
    emit RequestToFightz(pokeA, pokeb, block.timestamp);
  }

  function acceptChallenge(uint256 _pokemonReceiverid, uint256 _pokemonChallengerid) public {
    require(ownerOfPokemon[_pokemonReceiverid] == msg.sender, "You are not the owner");
    require(waitingForResponse[_pokemonReceiverid] == true, "not been invited to a challenge!");
    uint256 _number = numbss;
    require(sentAResponse[_pokemonChallengerid] == true, "Pokemon has not sent a Response!");
    acceptedRequest[_number] = true;

    emit NumberofFight(_number);
    numbss++;
    attackPokemons(_pokemonReceiverid, _pokemonChallengerid);
  }

  function cancelChallenge(
    uint256 pokemonA,
    uint256 _number // uint256 Timetime,
  ) public {
    require(ownerOfPokemon[pokemonA] == msg.sender, "You can not cancel this fight");
    require(acceptedRequest[_number] == false, "The battle already happened!!");
    // add a function here that reverses the action of initiating battle;
    require(sentAResponse[pokemonA] == true, "You have not initiated a fight");
    sentAResponse[pokemonA] = false;
  }

  function checkIfCooldownIsOver(uint256 _id) public view returns (uint256) {
    return pokemons[_id].currentLossCount;
  }

  function attackPokemons(uint256 challengedPokemonid, uint256 challengerPokemonid) public {
    require(ownerOfPokemon[challengedPokemonid] == msg.sender, "You don't own this pokemon");
    require(mintedPokemon[challengedPokemonid], "This Pokemon is not minted/ready yet ");
    require(mintedPokemon[challengerPokemonid], "Challenger pokemon is not minted yet");
    require(sentAResponse[challengerPokemonid] == true, "Enemy pokemon has not sent a response");
    require(pokemons[challengedPokemonid].currentLossCount < 2, "This pokemon is in cooldown");
    require(pokemons[challengerPokemonid].currentLossCount < 2, "This pokemon is in cooldown");
    uint256 randomNumber = randMod(100);
    _whoIsTheWinner(challengedPokemonid, challengerPokemonid, randomNumber);
  }

  function triggerCooldown(uint256 _id) internal {
    pokemons[_id].readyTime = uint32(block.timestamp + cooldownTime);
  }

  function battleReady(uint256 _id) internal {
    require(pokemons[_id].readyTime <= block.timestamp, "Cooldown has not been completed yet");
    pokemons[_id].currentLossCount = 0;
  }

  function _whoIsTheWinner(
    uint256 _challengedPokemonid,
    uint256 _challengerPokemonid,
    uint256 _randomNumber
  ) private {
    Pokemon memory myPokemon = pokemons[_challengedPokemonid];
    Pokemon memory enemyPokemon = pokemons[_challengerPokemonid];
    uint256 mypokemonPercent = (myPokemon.strength * 100);
    uint256 percentPokA = (mypokemonPercent / (myPokemon.strength + enemyPokemon.strength)) - 1;
    if (percentPokA < _randomNumber) {
      pokemons[_challengedPokemonid].winCount++;
      pokemons[_challengedPokemonid].currentLossCount = 0;
      pokemons[_challengerPokemonid].lossCount++;
      pokemons[_challengerPokemonid].currentLossCount++;
      emit BattleHappened(
        _challengerPokemonid,
        _challengedPokemonid,
        _battlenumber,
        block.timestamp,
        _challengedPokemonid
      );
      _battlenumber++;
      if (pokemons[_challengerPokemonid].currentLossCount == 2) {
        triggerCooldown(_challengerPokemonid);
      }
      if (myPokemon.strength >= enemyPokemon.strength) {
        pokemons[_challengedPokemonid].strength++;
        pokemons[_challengerPokemonid].strength--;
        if (pokemons[_challengerPokemonid].strength == 0) {
          burn(_challengerPokemonid);
        }
      }
      if (myPokemon.strength < enemyPokemon.strength) {
        uint256 _amount = (pokemons[_challengerPokemonid].strength /
          pokemons[_challengedPokemonid].strength);
        pokemons[_challengedPokemonid].strength += _amount;
        pokemons[_challengerPokemonid].strength -= _amount;
        if (pokemons[_challengerPokemonid].strength == 0) {
          burn(_challengerPokemonid);
        }
      }
    } else {
      pokemons[_challengerPokemonid].winCount++;
      pokemons[_challengerPokemonid].currentLossCount = 0;
      pokemons[_challengedPokemonid].lossCount++;
      pokemons[_challengedPokemonid].currentLossCount++;
      emit BattleHappened(
        _challengerPokemonid,
        _challengedPokemonid,
        _battlenumber,
        block.timestamp,
        _challengerPokemonid
      );
      _battlenumber++;
      if (pokemons[_challengedPokemonid].currentLossCount == 2) {
        triggerCooldown(_challengedPokemonid);
      }
      if (enemyPokemon.strength >= myPokemon.strength) {
        pokemons[_challengerPokemonid].strength++;
        pokemons[_challengedPokemonid].strength--;
        if (pokemons[_challengedPokemonid].strength == 0) {
          burn(_challengedPokemonid);
        }
      }
      if (enemyPokemon.strength < myPokemon.strength) {
        uint256 _amount = (pokemons[_challengedPokemonid].strength /
          pokemons[_challengerPokemonid].strength);
        pokemons[_challengerPokemonid].strength += _amount;
        pokemons[_challengedPokemonid].strength -= _amount;
        if (pokemons[_challengedPokemonid].strength == 0) {
          burn(_challengedPokemonid);
        }
      }
    }
    sentAResponse[_challengedPokemonid] = false;
  }
}

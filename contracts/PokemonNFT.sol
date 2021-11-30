// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PokemonNFT is ERC721URIStorage, Ownable, ERC721Burnable, ERC721Enumerable {
  using SafeMath for uint256;
  // using EnumerableMap for EnumerableMap.UintToAddressMap;
  // EnumerableMap.UintToAddressMap private pokemonMap;
  mapping(address => bool) internal approved;
  mapping(uint256 => bool) internal mintedPokemon;
  mapping(uint256 => address) internal ownerOfPokemon;
  mapping(address => uint256) internal ownedPokemonCount;
  mapping(uint256 => bool) internal waitingForFight;
  mapping(uint256 => bool) internal waitingForResponse;
  mapping(uint256 => bool) internal sentAResponse;
  mapping(uint256 => uint256) internal pokemonworth;
  mapping(uint256 => RequestToFight) internal requestid;
  mapping(uint256 => bool) internal acceptedRequest;
  uint256 public creationTimestamp;

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
  struct Battle {
    uint256 pokemonAID;
    uint256 pokemonBID;
    uint256 battleNumber;
    uint256 timeStamp;
    uint256 winnerOfBattle;
  }

  struct RequestToFight {
    uint256 pokemona;
    uint256 pokemonb;
    uint256 timestampOfRequest;
  }

  RequestToFight[] public requestsToFights;
  Pokemon[] public pokemons;
  Battle[] public battles;

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
  event NewPokemon(
    uint256 _tokenIds,
    string name,
    uint256 _age,
    Sex _sex,
    Colors color,
    uint256 strength
  );
  event BattleHappened(
    uint256 pokemonAID,
    uint256 pokemonBID,
    uint256 battleNumber,
    uint256 timeStamp,
    uint256 winnerOfBattle
  );

  event RequestToFightz(uint256 pokemonA, uint256 pokemonB, uint256 timestampOfRequest);

  constructor() ERC721("PokemonNFT", "PokNFT") {}

  function approvedForTransactions(address _user) public onlyOwner {
    approved[_user] = true;
  }

  function approvedOrNot(address _user) public view returns (bool) {
    return (approved[_user]);
  }

  modifier approvedForTrans() {
    require(approved[msg.sender], "not been approved yet");
    _;
  }

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
  {
    return super.tokenURI(tokenId);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}

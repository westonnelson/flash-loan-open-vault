pragma solidity ^0.5.15;

interface IDssCdpManager {
  function last(address proxy) external view returns (uint256);
}
pragma solidity ^0.5.15;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./interfaces/IDssCdpManager.sol";
import "./interfaces/IDSProxy.sol";
import "./GenerateCallData.sol";

contract MakerDAO is Ownable {

  // DAI Proxies
  // uint internal amount = 1000000000000000000000000000000;
  address public data_generation;
  address public dss_proxy;
  // MakerDAO Deployed Contracts
  address public dai_manager;
  address public dai_jug;
  address public dai_ethJoin;
  address public dai_daiJoin;
  address public vault_manager; // Proxy Actions

  bool public borrow_token;

  /* ------------------------ */
  // Setters
  /* ------------------------ */
  function setDataGeneration(address _data_generation) public onlyOwner {
    data_generation = _data_generation;
  }
  function setDssProxy(address _dss_proxy) public onlyOwner {
    dss_proxy = _dss_proxy;
  }
  function setVaultManager(address _vault_manager) public onlyOwner {
    vault_manager = _vault_manager;
  }
  function setJug(address _jug) public onlyOwner {
      dai_jug = _jug;
  }
  function setEthJoin(address _ethJoin) public onlyOwner {
      dai_ethJoin = _ethJoin;
  }
  function setDaiJoin(address _daiJoin) public onlyOwner {
      dai_daiJoin = _daiJoin;
  }

  function setDAIAddresses(
      address _dai_manager,
      address _dai_jug,
      address _dai_ethJoin,
      address _dai_daiJoin
      ) public onlyOwner {
        dai_manager = _dai_manager;
        dai_jug = _dai_jug;
        dai_ethJoin = _dai_ethJoin;
        dai_daiJoin = _dai_daiJoin;
    }

  /* ------------------------ */
  // Getters
  /* ------------------------ */
  function getLastCDP(address _proxy) public view returns (uint256) {
      IDssCdpManager manager = IDssCdpManager(dai_manager);
      uint last = manager.last(_proxy);
      return last;
    }

  /* ------------------------ */
  // Functions
  /* ------------------------ */
  function callVaultManager (bytes memory _data) public payable {
    IDSProxy proxy = IDSProxy(dss_proxy);
    proxy.execute.value(msg.value)(vault_manager, _data);
  }

  function callVaultManager (uint256 _amount, bytes memory _data) public {
    IDSProxy proxy = IDSProxy(dss_proxy);
    proxy.execute.value(_amount)(vault_manager, _data);
  }
  
  // ETH Vault Functions
  /* ------------------------ */
  function openETHVault(
        uint wadD, 
        bytes32 ilk
    ) public payable {
        GenerateCallData proxy = GenerateCallData(data_generation);
        bytes memory data = proxy.openLockETHAndDraw(
            dai_manager,
            dai_jug,
            dai_ethJoin,
            dai_daiJoin,
            ilk,
            wadD
        );
        callVaultManager(data);
    }
  
  function openETHVault(
      uint _amount,
      uint wadD, 
      bytes32 ilk
    ) public {
        GenerateCallData proxy = GenerateCallData(data_generation);
        bytes memory data = proxy.openLockETHAndDraw(
            dai_manager,
            dai_jug,
            dai_ethJoin,
            dai_daiJoin,
            ilk,
            wadD
        );
        callVaultManager(_amount, data);
    }

  function closeETHVault(
      uint cdp,
      uint wadD
    ) public payable {
      GenerateCallData proxy = GenerateCallData(data_generation);
      bytes memory data = proxy.wipeAllAndFreeETH(
          dai_manager,
          dai_ethJoin,
          dai_daiJoin,
          cdp,
          wadD
      );
      callVaultManager(0x0, data);
    }

    // Gem Vault Functions
    /* ------------------------ */
    function openGemVault(
        address gemJoin,
        bytes32 ilk,
        uint amtC,
        uint wadD, 
        bool transferFrom
    ) public payable {
        GenerateCallData proxy = GenerateCallData(data_generation);
        bytes memory data = proxy.openLockGemAndDraw(
            dai_manager,
            dai_jug,
            gemJoin,
            dai_daiJoin,
            ilk,
            amtC,
            wadD,
            transferFrom
        );
        callVaultManager(0x0,data);
    }


  function closeGemVault(
      address _gemJoin,
      uint _cdp,
      uint _amtC
    ) public payable {
      GenerateCallData proxy = GenerateCallData(data_generation);
      bytes memory data = proxy.wipeAllAndFreeGem(
          dai_manager,
          _gemJoin,
          dai_daiJoin,
          _cdp,
          _amtC
      );
      callVaultManager(0x0, data);
    }


    /* ------------------------ */
    // Functions
    /* ------------------------ */
    function openClosePosition(
      uint _wadD,
      bytes32 _ilk
    ) payable public {
      openETHVault(_wadD, _ilk);
      uint256 _payed = msg.value;
      uint256 cdp = getLastCDP(dss_proxy);
      closeETHVault(cdp, _payed);
    }

    function openCloseGemPosition(
      address _gemJoin, 
      bytes32 _ilk,
      uint _amtC,
      uint _wadD, 
      bool _transferFrom
    ) public {
      openGemVault(_gemJoin, _ilk, _amtC, _wadD, _transferFrom);
      uint256 cdp = getLastCDP(dss_proxy);
      closeGemVault(_gemJoin, cdp, _amtC);
    }
}
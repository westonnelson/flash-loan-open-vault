# Aave Flash Loan & MakerDAO Vaults Smart Contract

An Aave Flash Loan and MakerDAO CDP (Vault) smart contract example to demonstrate using a FlashLoan to to open a MakerDAO CDP withdraw DAI using the leveraged collateral.

## Instructions

- Deploy `FlashLoan` Smart Contract to blockchain.
- Create `FlashLoan` MakerDAO Proxy contract
  - mainnet (https://etherscan.io/address/0x4678f0a6958e4d2bc4f1baf7bc52e8f3564f3fe4#writeContract)
  - kovan (https://kovan.etherscan.io/address/0x64A436ae831C1672AE81F674CAb8B6775df3475C#writeContract)
- Set MakerDAO Proxy Contracts (http://changelog.makerdao.com/)
- Deploy `GenerateCallData` Smart Contract to blockchain.
- Set GenerateCallData Proxy Contracts (http://changelog.makerdao.com/)
- Execute FlashLoan.

## Deploy

The smart contracts can be deployed using a number of different methods. To continue to interact with the deployed smart contracts we recommend using the OpenZeppelin CLI

Setup the project using the OpenZeppelin CLI to easily interact with deployed contracts directly from the CLI.

### Open Zeppelin

```.sh
$ oz init
$ oz deploy
```

### Truffle

```.sh
$ truffle compile
$ truffle deploy --network [NETWORK]
```

## Send Transactions

If the contracts are deployed using the OpenZeppelin CLI you can continue to interact with contracts using several CLI commands.

```
$ oz call
$ oz send-tx
```

## Contributors

| Name               | Website                      |
| ------------------ | ---------------------------- |
| **Kames Geraghty** | <https://github.com/kamescg> |

## License

[MIT](LICENSE) © [Ethereum Developer Alliance](https://github.com/EthereumDeveloperAlliance)

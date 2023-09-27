# CELO-FE-101

![Alt text](./packages/react-app/public/demo.png "Demo")

# Description
Welcome to Celo FrontEnd 101, a web application enable user to view, buy, add, update and delete their own product in the marketplace. Users can buy multiple products from different sellers. It uses the Celo Eur stable currency.

# Feature

1. View list of products in the marketplace
2. Add new products
3. Allows users to buy multiple products from different sellers at a time
4. Implements a cart based system
5. Sellers can view how much they've made in sales and withdraw amount to their wallets.
6. Edit or delete your own product

# Tech Stack
This web aplication uses the following tech stack:
- [Solidity](https://docs.soliditylang.org/) - A programming language for Ethereum smart contracts.
- [React](https://reactjs.org/) - A JavaScript library for building user interfaces.
- [Typescript](https://www.typescriptlang.org) - a strongly typed programming language that builds on JavaScript.
- [Rainbowkit-celo](https://docs.celo.org/developer/rainbowkit-celo) - RainbowKit is a React library that makes it easy to add wallet connection to dapp.
- [Wagmi](https://wagmi.sh) - wagmi is a collection of React Hooks containing everything you need to start working with Ethereum
- [Hardhat](https://hardhat.org/) - A tool for writing and deploying smart contracts.
- [TailwindCss](https://tailwindcss.com) - A CSS framework that dress up webpage.

# Installation
To run the application locally, follow these steps:

1. Clone the repository to your local machine using: ``` git clone https://github.com/JoE11-y/celo-fe-101.git ```
2. Move into react-app folder: ``` cd celo-fe-101/packages/react-app ```
3. Install: ``` npm install ``` or ``` yarn install ```
4. Start: ``` npm run dev ```
5. Open the application in your web browser at ``` http://localhost:3000 ```

# Usage
1. Install a wallet: [MetamaskExtensionWallet](https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn?hl=en).
2. Create a wallet.
3. Go to [https://faucet.celo.org/alfajores](https://faucet.celo.org/alfajores) and get tokens for the alfajores testnet.
4. Switch to the alfajores testnet.
5. Connect your wallet to the app.
6. Create multiple products.
7. Create a second account in your extension wallet.
8. Add products to your cart
9. Checkout from cart and pay
10. Check balance
11. Switch to first account and check sales
12. Then withdraw money in sales to first account

# Contributing
1. Fork this repository
2. Create a new branch for your changes: git checkout -b my-feature-branch
3. Make your changes and commit them: git commit -m "feat: create new feature"
4. Push your changes to your fork: git push origin my-feature-branch
5. Open a pull request to this repository with a description of your changes

Please make sure that your code follows the Solidity Style Guide and the React Style Guide. You can add tests for any new features or changes, also please make the front-end more friendly. I welcome any contributions or feedback on this project!

// SPDX-License-Identifier: MIT

// Version of Solidity compiler this program was written for
pragma solidity >=0.7.0 <0.9.0;

// Interface for the ERC20 token, in our case cUSD
interface IERC20Token {
    // Transfers tokens from one address to another
    function transfer(address, uint256) external returns (bool);

    // Approves a transfer of tokens from one address to another
    function approve(address, uint256) external returns (bool);

    // Transfers tokens from one address to another, with the permission of the first address
    function transferFrom(address, address, uint256) external returns (bool);

    // Returns the total supply of tokens
    function totalSupply() external view returns (uint256);

    // Returns the balance of tokens for a given address
    function balanceOf(address) external view returns (uint256);

    // Returns the amount of tokens that an address is allowed to transfer from another address
    function allowance(address, address) external view returns (uint256);

    // Event for token transfers
    event Transfer(address indexed from, address indexed to, uint256 value);
    // Event for approvals of token transfers
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// Contract for the marketplace
contract Marketplace {
    // Keeps track of the number of products in the marketplace
    uint256 internal productsLength = 0;
    // Address of the cEURToken
    address internal cEURTokenAddress = 0x10c892A6EC43a53E45D0B916B4b7D383B1b78C0F;

    // Structure for a product
    struct Product {
        // Address of the product owner
        address payable owner;
        // Name of the product
        string name;
        // Link to an image of the product
        string image;
        // Description of the product
        string description;
        // Location of the product
        string location;
        // Price of the product in tokens
        uint256 price;
        // Number of times the product has been sold
        uint256 sold;
    }

    // Structure for an order
    struct CartItem {
        uint256 productId;     
        uint256 quantity;
    }

    // Mapping of products to their index
    mapping(uint256 => Product) internal products;

    // Mapping showing if a product exists
    mapping(uint256 => bool) internal productExists;

    // Mapping containing product owner balance in contract
    mapping(address => uint256) internal ownerBalance;

    modifier isOwner(uint _index, address caller) {
        require(products[_index].owner == caller, "not owner");
        _;
    }

    // Writes a new product to the marketplace
    function writeProduct(
        string memory _name,
        string memory _image,
        string memory _description,
        string memory _location,
        uint256 _price
    ) public {
        // Add check to ensure that price of product is greater than 0
        require(_price > 0, "Price must be greater than 0");
        // Number of times the product has been sold is initially 0 because it has not been sold yet
        uint256 _sold = 0;
        // Adds a new Product struct to the products mapping
        products[productsLength] = Product(
            // Sender's address is set as the owner
            payable(msg.sender),
            _name,
            _image,
            _description,
            _location,
            _price,
            _sold
        );
        // Set that the product with product id exists
        productExists[productsLength] = true;
        // Increases the number of products in the marketplace by 1
        productsLength++;
    }

    // Reads a product from the marketplace
    function readProduct(
        // Index of the product
        uint256 _index
    )
        public
        view
        returns (
            address payable,
            string memory,
            string memory,
            string memory,
            string memory,
            uint256,
            uint256
        )
    {
        // Returns the details of the product
        return (
            products[_index].owner,
            products[_index].name,
            products[_index].image,
            products[_index].description,
            products[_index].location,
            products[_index].price,
            products[_index].sold
        );
    }

    // Places order to buy products from the marketplace
    function placeOrder(CartItem[] memory _cartItems) public payable {
        uint256 _totalAmount;
        for (uint256 i = 0; i < _cartItems.length; i++) {
            // get order
            CartItem memory _item = _cartItems[i];
            // check if product exists in contract
            require(productExists[_item.productId] == true, "Product does not exist");
            // get product
            Product storage _product = products[_item.productId];
            // calculate total amount to sent
            _totalAmount += _product.price * _item.quantity;
            // add balance to product owner mapping
            ownerBalance[_product.owner] += _product.price * _item.quantity;
            // update number of products sold
            _product.sold += _item.quantity;
        }
        
        // transfer amount
        require(
            IERC20Token(cEURTokenAddress).transferFrom(
                // Sender's address is the buyer
                msg.sender,
                // Receiver's address is the contract
                address(this),
                // Amount of tokens to transfer is the total amount of order
                _totalAmount
            ),
            // If transfer fails, throw an error message
            "Transfer failed."
        );
    }

    // Product owner withdraw funds from contract
    function withdrawFunds() public payable {
        require(ownerBalance[msg.sender] > 0, "Empty balance");

        uint256 amountToSend = ownerBalance[msg.sender];
        ownerBalance[msg.sender] = 0;

        // transfer amount
        require(IERC20Token(cEURTokenAddress).transfer(payable(msg.sender), amountToSend), "Transfer failed");
    }

    // Remove a product from the marketplace
    function removeProduct(
        uint _indexToRemove
    ) public isOwner(_indexToRemove, msg.sender) {
        delete (products[_indexToRemove]);
        productExists[_indexToRemove] = false;
    }


    // Update pricing of a product from the marketplace
    function updateProduct(
        uint _indexToUpdate,
        uint _newPrice
    ) public isOwner(_indexToUpdate, msg.sender) {
        products[_indexToUpdate].price = _newPrice;
    }

    // Returns the number of products in the marketplace
    function getProductsLength() public view returns (uint256) {
        return (productsLength);
    }

    // Return Balance of Owner
    function getBalance(address _owner) public view returns(uint256){
        return ownerBalance[_owner];
    }
}

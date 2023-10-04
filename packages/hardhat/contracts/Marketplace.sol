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

/**
 * @title Marketplace
 * @dev This contract represents a decentralized marketplace for products.
 */
contract Marketplace {
    // Keeps track of the number of products in the marketplace
    uint256 internal productsLength = 0;
    // Address of the cEURToken
    address internal cEURTokenAddress;

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

    /**
     * @dev Modifier to check if the caller is the owner of a product.
     * @param _index The index of the product in the products mapping.
     */
    modifier isOwner(uint256 _index) {
        require(products[_index].owner == msg.sender, "Not owner");
        _;
    }

    /**
     * @dev Constructor to initialize the marketplace with the address of the cEURToken.
     * @param _cEURTokenAddress The address of the cEURToken.
     */
    constructor(address _cEURTokenAddress) {
        cEURTokenAddress = _cEURTokenAddress;
    }

    /**
     * @dev Writes a new product to the marketplace.
     * @param _name The name of the product.
     * @param _image The link to an image of the product.
     * @param _description The description of the product.
     * @param _location The location of the product.
     * @param _price The price of the product in tokens.
     */
    function writeProduct(
        string memory _name,
        string memory _image,
        string memory _description,
        string memory _location,
        uint256 _price
    ) public {
        require(_price > 0, "Price must be greater than 0");
        uint256 _sold = 0;
        products[productsLength] = Product(
            payable(msg.sender),
            _name,
            _image,
            _description,
            _location,
            _price,
            _sold
        );
        productExists[productsLength] = true;
        productsLength++;
    }

    /**
     * @dev Reads the details of a product from the marketplace.
     * @param _index The index of the product in the products mapping.
     * @return Details of the product, including owner, name, image link, description, location, price, and number of times sold.
     */
    function readProduct(uint256 _index)
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

    /**
     * @dev Places an order to buy products from the marketplace.
     * @param _cartItems An array of CartItem structs representing the products and their quantities to buy.
     */
    function placeOrder(CartItem[] memory _cartItems) public payable {
        uint256 _totalAmount;
        for (uint256 i = 0; i < _cartItems.length; i++) {
            CartItem memory _item = _cartItems[i];
            require(productExists[_item.productId], "Product does not exist");
            Product storage _product = products[_item.productId];
            uint256 _orderAmount = _product.price * _item.quantity;
            _totalAmount += _orderAmount;
            ownerBalance[_product.owner] += _orderAmount;
            _product.sold += _item.quantity;
        }
        
        require(
            IERC20Token(cEURTokenAddress).transferFrom(
                msg.sender,
                address(this),
                _totalAmount
            ),
            "Transfer failed."
        );
    }

    /**
     * @dev Allows the product owner to withdraw their funds from the contract.
     */
    function withdrawFunds() public {
        uint256 balance = ownerBalance[msg.sender];
        require(balance > 0, "Empty balance");
        ownerBalance[msg.sender] = 0;
        require(
            IERC20Token(cEURTokenAddress).transfer(payable(msg.sender), balance),
            "Transfer failed"
        );
    }

    /**
     * @dev Removes a product from the marketplace. Only the owner of the product can perform this action.
     * @param _indexToRemove The index of the product in the products mapping to be removed.
     */
    function removeProduct(uint256 _indexToRemove) public isOwner(_indexToRemove) {
        delete products[_indexToRemove];
        productExists[_indexToRemove] = false;
    }

    /**
     * @dev Updates the price of a product in the marketplace. Only the owner of the product can perform this action.
     * @param _indexToUpdate The index of the product in the products mapping to be updated.
     * @param _newPrice The new price for the product.
     */
    function updateProduct(uint256 _indexToUpdate, uint256 _newPrice) public isOwner(_indexToUpdate) {
        products[_indexToUpdate].price = _newPrice;
    }

    /**
     * @dev Returns the number of products in the marketplace.
     * @return The total number of products.
     */
    function getProductsLength() public view returns (uint256) {
        return productsLength;
    }

    /**
     * @dev Returns the balance of a product owner in the contract.
     * @param _owner The address of the product owner.
     * @return The balance of the product owner.
     */
    function getBalance(address _owner) public view returns(uint256){
        return ownerBalance[_owner];
    }

    receive() external payable {
        // Fallback function to receive Ether (if needed)
    }
}

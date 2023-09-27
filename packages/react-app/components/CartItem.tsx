import React, { ReactComponentElement } from "react";
// Import ethers to format the price of the product correctly
import { ethers } from "ethers";
import { useCart, CartItem } from "@/context/CartContext";
import { TrashIcon } from "@heroicons/react/24/outline";

interface Props {
  item: CartItem;
}

export const CartItemView = ({ item }: Props) => {
  const { removeFromCart, updateCartItemQuantity } = useCart();

  const handleQuantityChange = (qty: number, e: React.MouseEvent<HTMLButtonElement>) => {
    e.preventDefault();
    const quantity = Number(qty);
    if (quantity >= 1) {
      updateCartItemQuantity(item.product.id, quantity);
    }
  };
  // Format the price of the product from wei to cUSD otherwise the price will be way too high
  const productPriceFromWei = ethers.utils.formatEther(
    item.product.price.toString()
  );

  const handleRemoveClick = () => {
    removeFromCart(item.product.id);
  };

  return (
    <div className="grid grid-cols-12 gap-4">
      {/* Product Image and Title */}
      <div className="flex flex-col items-center col-span-12 sm:col-span-5">
        <div>
          <p className="text-lg">{item.product.name}</p>
        </div>
      </div>
      {/* Product Quantity */}
      <div className="flex items-center col-span-12 sm:col-span-5">
        <div className="space-x-10 flex items-center">
          <p className="text-lg">
            €{(Number(productPriceFromWei) * item.quantity).toFixed(2)}
          </p>
          <div className="flex items-center space-x-2">
            {/* Increasing/Decreasing Product Quantity Button */}
            <button
              aria-label="decrease"
              onClick={(e) => handleQuantityChange(item.quantity - 1, e)}
            >
              -
            </button>
            <p className="text-gray-500 text-lg">{item.quantity}</p>
            <button
              aria-label="increase"
              onClick={(e) => handleQuantityChange(item.quantity + 1, e)}
            >
             +
            </button>
          </div>
        </div>
      </div>
      {/* Removing Product From Cart */}
      <div className="col-span-12 sm:col-span-2 flex items-center">
        <button
          aria-label="remove"
          className="text-red-500 text-3xl"
          onClick={handleRemoveClick}
        >
           <TrashIcon className="block h-6 w-6" aria-hidden="true" />
        </button>
      </div>
    </div>
  );
};

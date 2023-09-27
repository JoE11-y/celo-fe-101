import React from "react";
import { CartItemView } from "@/components/CartItem"; // Assuming CartItemView is a default React component
import { useCart } from "@/context/CartContext";
// Import ethers to format the price of the product correctly
import { ethers } from "ethers";

const CartView = () => {
  const { cartItems, cartTotal } = useCart();
    // Format the price of the product from wei to cUSD otherwise the price will be way too high
    const cartTotalFromWei = ethers.utils.formatEther(
        cartTotal.toString()
      );

  return (
    <div className="container mx-auto py-8">
      <h1 className="text-center text-3xl mb-10">Shopping Cart</h1>
      {cartItems.length === 0 ? (
        <p className="text-center text-xl">Your cart is empty</p>
      ) : (
        <>
          {/* Listing all items in the cart */}
          {cartItems.map((item) => (
            <div key={item.product.id} className="mb-6">
              <CartItemView item={item} />
            </div>
          ))}

          <hr className="my-2" />

          <div className="mt-2">
            <p className="text-xl flex flex-row">Total Cost: €{cartTotalFromWei} cEUR</p>
          </div>
        </>
      )}
    </div>
  );
};

export default CartView;

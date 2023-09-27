// This component is used to add a product to the marketplace and show the user's cEUR balance

// Importing the dependencies
import { useState } from "react";
// import ethers to convert the product price to wei
import { ethers } from "ethers";
// Import the useAccount hook to get the user's address
import { useAccount } from "wagmi";
// Import the useConnectModal hook to trigger the wallet connect modal
import { useConnectModal } from "@rainbow-me/rainbowkit";
// Import the toast library to display notifications
import { toast } from "react-toastify";
// Import our custom hooks to interact with the smart contract
import { useContractSend } from "@/hooks/contract/useContractWrite";
import { useContractApprove } from "@/hooks/contract/useApprove";
// Import Cart Icon
import { ShoppingCartIcon } from "@heroicons/react/24/outline";
// Import Usecart from context to get order details
import { useCart } from "@/context/CartContext";

import CartView from "../CartView";

// The Cart component is used to show items in user order
const Cart = () => {
    // Use the useAccount hook to store the user's address
    const { address } = useAccount();
  // The visible state is used to toggle the modal
  const [visible, setVisible] = useState(false);
 
  // The loading state is used to display a loading message
  const [loading, setLoading] = useState("");

  const {cartItems, cartTotal, clearCart} = useCart();

  // Use the useConnectModal hook to trigger the wallet connect modal
  const { openConnectModal } = useConnectModal();

  // Use the useContractSend hook to purchase the product with the id passed in, via the marketplace contract
  const { writeAsync: purchase, isSuccess: isSuccess } = useContractSend(
    "placeOrder",
    [cartItems]
  );
    
  // Use the useContractApprove hook to approve the spending of the product's price, for the ERC20 cUSD contract
    const { writeAsync: approve } = useContractApprove(
      cartTotal.toString() || "1"
    );

  // Define the handlePurchase function which handles the purchase interaction with the smart contract
  const handlePurchase = async () => {
    if (!approve || !purchase) {
      throw "Failed to purchase this product";
    }
    // Approve the spending of the product's price, for the ERC20 cUSD contract
    const approveTx = await approve();
    // Wait for the transaction to be mined, (1) is the number of confirmations we want to wait for
    await approveTx.wait(1);
    setLoading("Purchasing...");
    // Once the transaction is mined, purchase the product via our marketplace contract buyProduct function
    const res = await purchase();
    // Wait for the transaction to be mined
    await res.wait();
    // Close the modal and clear the input fields after the product is added to the marketplace
    setVisible(false);
    // Clear the cart
    clearCart();
  };

    // Define the purchaseProduct function that is called when the user clicks the purchase button
    const purchaseProduct = async (e:any) => {
      e.preventDefault();

      setLoading("Approving ...");
      try {
        // If the user is not connected, trigger the wallet connect modal
        if (!address && openConnectModal) {
          openConnectModal();
          return;
        }
        // If the user is connected, call the handlePurchase function and display a notification
        await toast.promise(handlePurchase(), {
          pending: "Purchasing product...",
        });
        if (isSuccess) {
          toast.success("Product purchased successfully");
        }
        // If there is an error, display the error message
      } catch (e: any) {
        console.log({ e });
        toast.error(e?.reason || e?.message || "Something went wrong. Try again.");
        // Once the purchase is complete, clear the loading state
      } finally {
        setLoading("");
      }
    };

  // Define the JSX that will be rendered
  return (
    <div className={"flex flex-row w-full justify-between"}>
      <div>
        {/* Add Product Button that opens the modal */}
        <button
          type="button"
          onClick={() => setVisible(true)}
          className="inline-flex items-center px-1 pt-1 text-sm font-medium text-gray-900"
          data-bs-toggle="modal"
          data-bs-target="#exampleModalCenter">
            <div className="px-6 py-2.5 hover:bg-gray-700 hover:shadow-lg focus:bg-gray-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-gray-800 active:shadow-lg transition duration-150 ease-in-out">
              Cart
              <ShoppingCartIcon className="block h-6 w-6" aria-hidden="true" />
            </div>
        </button>

        {/* Modal */}
        {visible && (
          <div
            className="fixed z-40 overflow-y-auto top-0 w-full left-0"
            id="modal">
            {/* Form with input fields for the product, that triggers the addProduct function on submit */}
            <form onSubmit={purchaseProduct}
              >
              <div className="flex items-center justify-center min-height-100vh pt-4 px-4 pb-20 text-center sm:block sm:p-0">
                <div className="fixed inset-0 transition-opacity">
                  <div className="absolute inset-0 bg-gray-900 opacity-75" />
                </div>
                <span className="hidden sm:inline-block sm:align-middle sm:h-screen">
                  &#8203;
                </span>
                <div
                  className="inline-block align-center bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full"
                  role="dialog"
                  aria-modal="true"
                  aria-labelledby="modal-headline">
                  <div className="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                    <CartView />
                  </div>
                  {/* Button to close the modal */}
                  <div className="bg-gray-200 px-4 py-3 text-right">
                    <button
                      type="button"
                      className="py-2 px-4 bg-gray-500 text-white rounded hover:bg-gray-700 mr-2"
                      onClick={() => setVisible(false)}>
                      <i className="fas fa-times"></i> Cancel
                    </button>
                    {/* Button to add the product to the marketplace */}
                    <button
                      type="submit"
                      // disabled={!!loading || !purchase || !approve}
                      className="py-2 px-4 bg-blue-500 text-white rounded hover:bg-blue-700 mr-2">
                      {loading ? loading : "Checkout"}
                    </button>
                  </div>
                </div>
              </div>
            </form>
          </div>
        )}
      </div>
    </div>
  );
};

export default Cart;

import React, { useEffect, useState } from "react";
import { NativeAssetId, Wallet } from "fuels";
import "./App.css";
// Import the contract factory -- you can find the name in index.ts.
// You can also do command + space and the compiler will suggest the correct name.
import { LEarnContractAbi__factory } from "./contracts";

// The address of the contract deployed the Fuel testnet
const CONTRACT_ID =
  "0x14f92d1905ad2f1c7c4516c39534cd59cec0d9641055fa22eacc4277500603d3";

//the private key from createWallet.js
const WALLET_SECRET =
  "0xeb601fddd158c82e2c40a93f00373d2f56745fbe0bfb5c3b36cd28e2bdfa2a98";

// Create a Wallet from given secretKey in this case
// The one we configured at the chainConfig.json
const wallet = Wallet.fromPrivateKey(
  WALLET_SECRET,
  "https://beta-3.fuel.network/graphql"
);

console.log(wallet);

// Connects out Contract instance to the deployed contract
// address using the given wallet.
const contract = LEarnContractAbi__factory.connect(CONTRACT_ID, wallet);

function App() {
  const [loading1, setLoading1] = useState(false);
  const [loading2, setLoading2] = useState(false);
  const [loading3, setLoading3] = useState(false);
  const [loading4, setLoading4] = useState(false);
  const [loading5, setLoading5] = useState(false);
  const [loading6, setLoading6] = useState(false);
  const [loading7, setLoading7] = useState(false);
  const [loading8, setLoading8] = useState(false);

  useEffect(() => {
    async function main() {
      // Executes the counter function to query the current contract state
      // the `.get()` is read-only, because of this it don't expand coins.
    }
    main();
  }, []);

  async function create_course() {
    // a loading state
    setLoading1(true);
    // Creates a transactions to call the increment function
    // because it creates a TX and updates the contract state this requires the wallet to have enough coins to cover the costs and also to sign the Transaction
    try {
      const { value } = await contract.functions.create_course(10000000, 4, [1, 2, 3, 4], [10, 20, 30, 40, 500, 600, 700, 800]).txParams({ gasPrice: 1 }).call();
      console.log(value);
    } finally {
      console.log("Executed Create Course");
      setLoading1(false);
    }
  }

  async function section_completed() {
    // a loading state
    setLoading7(true);
    // Creates a transactions to call the increment function
    // because it creates a TX and updates the contract state this requires the wallet to have enough coins to cover the costs and also to sign the Transaction
    try {
      await contract.functions.section_completed(0, 3).txParams({ gasPrice: 1 }).call();
    } finally {
      console.log("Executed Section Completed");
      setLoading7(false);
    }
  }

  async function enroll_course() {
    // a loading state
    setLoading4(true);
    // Creates a transactions to call the increment function
    // because it creates a TX and updates the contract state this requires the wallet to have enough coins to cover the costs and also to sign the Transaction
    try {
      await contract.functions.enroll_course(0).callParams({forward : {amount : 10000000, assetId : NativeAssetId}}).txParams({ gasPrice: 1 }).call();
    } finally {
      console.log("Executed Enroll Course");
      setLoading4(false);
    }
  }

  async function get_user_database() {
    // a loading state
    setLoading5(true);
    // Creates a transactions to call the increment function
    // because it creates a TX and updates the contract state this requires the wallet to have enough coins to cover the costs and also to sign the Transaction
    try {
      const { value } = await contract.functions.get_user_database(0).txParams({ gasPrice: 1 }).call();
      console.log(value);
    } finally {
      setLoading5(false);
    }
  }

  async function get_user_data() {
    // a loading state
    setLoading8(true);
    // Creates a transactions to call the increment function
    // because it creates a TX and updates the contract state this requires the wallet to have enough coins to cover the costs and also to sign the Transaction
    try {
      const { value } = await contract.functions.get_user_data().txParams({ gasPrice: 1 }).call();
      console.log(value);
    } finally {
      setLoading8(false);
    }
  }

  async function get_course_database() {
    // a loading state
    setLoading2(true);
    // Creates a transactions to call the increment function
    // because it creates a TX and updates the contract state this requires the wallet to have enough coins to cover the costs and also to sign the Transaction
    try {
      const { value } = await contract.functions.get_course_database(0).get();
      console.log(value);
    } finally {
      setLoading2(false);
    }
  }

  async function get_course_id() {
    // a loading state
    setLoading3(true);
    // Creates a transactions to call the increment function
    // because it creates a TX and updates the contract state this requires the wallet to have enough coins to cover the costs and also to sign the Transaction
    try {
      const { value } = await contract.functions.get_course_id().get();
      console.log(value);
    } finally {
      setLoading3(false);
    }
  }

  async function get_contract_balance() {
    // a loading state
    setLoading6(true);
    // Creates a transactions to call the increment function
    // because it creates a TX and updates the contract state this requires the wallet to have enough coins to cover the costs and also to sign the Transaction
    try {
      const { value } = await contract.functions.get_contract_balance().get();
      console.log(value);
    } finally {
      setLoading6(false);
    }
  }
  
  return (
    <div className="App">
      <header className="App-header">
        <button disabled={loading1} onClick={create_course}>
          {loading1 ? "Executing..." : "Create Course"}
        </button>
        <br></br>
        <button disabled={loading2} onClick={get_course_database}>
          {loading2 ? "Executing..." : "Get Course Database"}
        </button>
        <br></br>
        <button disabled={loading3} onClick={get_course_id}>
          {loading3 ? "Executing..." : "Get Course Id"}
        </button>
        <br></br>
        <button disabled={loading4} onClick={enroll_course}>
          {loading4 ? "Executing..." : "Enroll Course"}
        </button>
        <br></br>
        <button disabled={loading5} onClick={get_user_database}>
          {loading5 ? "Executing..." : "Get User Database"}
        </button>
        <br></br>
        <button disabled={loading6} onClick={get_contract_balance}>
          {loading6 ? "Executing..." : "Get Contract Balance"}
        </button>
        <br></br>
        <button disabled={loading7} onClick={section_completed}>
          {loading7 ? "Executing..." : "Section Completed"}
        </button>
        <br></br>
        <button disabled={loading8} onClick={get_user_data}>
          {loading8? "Executing..." : "Get User Data"}
        </button>
      </header>
    </div>
  );
}
export default App;

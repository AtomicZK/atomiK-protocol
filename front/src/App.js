import "./App.css";
import Header from "./components/Header";
import Swap from "./components/Swap";
import { Routes, Route } from "react-router-dom";
import { useConnect, useAccount } from "wagmi";
import { MetaMaskConnector } from "wagmi/connectors/metaMask";

import contract from "./assets/contracts/Atomic.json";
import deployment from "./assets/contracts/run-latest.json";


export const AtomicContract = {
  abi: contract.abi,
  address: deployment.transactions[0].contractAddress,
};

// export const forkMainnet: Chain = {
//   ...mainnet,
//   name: "Forked Mainnet",
//   rpcUrls: {
//     default: { http: ['http://localhost:8545'] },
//     public: { http: ['http://localhost:8545'] },
//   }
// }

function App() {
  const { address, isConnected } = useAccount();
  const { connect } = useConnect({
    connector: new MetaMaskConnector(),
  });

  return (

    <div className="App">
      <Header connect={connect} isConnected={isConnected} address={address} />
      <div className="mainWindow">
        <Routes>
          <Route path="/" element={<Swap isConnected={isConnected} address={address} />} />
        </Routes>
      </div>

    </div>
  )
}

export default App;

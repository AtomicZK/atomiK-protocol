import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import App from "./App";
import { BrowserRouter } from "react-router-dom";
import { configureChains, WagmiConfig, createConfig } from "wagmi";
import { publicProvider } from 'wagmi/providers/public'
import { gnosis, gnosisChiado, scrollTestnet, xdc, xdcTestnet, zkSync, zkSyncTestnet } from 'wagmi/chains'

const { publicClient, webSocketPublicClient } = configureChains(
  [gnosis, gnosisChiado, scrollTestnet, xdc, xdcTestnet, zkSync, zkSyncTestnet ],
  [publicProvider()],
);

const config = createConfig({
  autoConnect: true,
  publicClient,
  webSocketPublicClient,
})

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    <WagmiConfig config={config}>
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </WagmiConfig>
  </React.StrictMode>
);

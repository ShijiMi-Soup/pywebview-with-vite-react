import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App.tsx";
import "./index.css";

declare global {
  interface Window {
    pywebview: {
      api: {
        [key: string]: (...args: unknown[]) => Promise<unknown>;
      };
      [key: string]: unknown;
    };
  }
}

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

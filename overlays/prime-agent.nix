final: prev: {
  llm-agents = prev.llm-agents // {
    prime-agent = prev.llm-agents.prime-agent.override {
      # The MCP 2 SDK uses httpx2, which stable nixpkgs does not package yet.
      # Use unstable Python 3.13, which supplies httpx2 and httpcore2, rather
      # than maintaining local wheel derivations for those dependencies.
      python3 = final.unstable.python313;
    };
  };
}

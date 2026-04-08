final: prev:
{
  seclists = prev.seclists.overrideAttrs ( old: rec {
    version = "2026.1";
    src = prev.fetchFromGitHub {
      owner = old.src.owner;
      repo = old.src.repo;
      rev = version;
      hash = "sha256-S1C+/gX3mvCC9OVxzCO6PrzbvxCz5mTWEXrBqzSuKps=";
    };
  });
}

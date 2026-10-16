# bump: version + Claude-<rev>.zip url from homebrew-cask Casks/c/claude.rb,
# then: nix store prefetch-file --hash-type sha256 <url>
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "claude-desktop";
  version = "1.20186.0";

  src = fetchurl {
    url = "https://downloads.claude.ai/releases/darwin/universal/${version}/Claude-d7731e7f42fb72db87a6488ad8c1357b1cf971f7.zip";
    hash = "sha256-NP4p6z16zGP+jnMgmG6K7hIwS7NH5NA76s5tfWJ57kw=";
  };

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -R "Claude.app" "$out/Applications/Claude.app"
    runHook postInstall
  '';

  meta = {
    description = "Anthropic's official Claude AI desktop app";
    homepage = "https://claude.com/download";
    license = lib.licenses.unfree;
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    mainProgram = "Claude";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}

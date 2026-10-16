# bump: new rev, then:
#   nix store prefetch-file --unpack --hash-type sha256 \
#     https://github.com/darfink/vim-plist/archive/<rev>.tar.gz
{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin {
  pname = "vim-plist";
  version = "2026-07-04";
  src = fetchFromGitHub {
    owner = "darfink";
    repo = "vim-plist";
    rev = "aa781a387c70a9ea30cbce8da988e19693f5aaec";
    sha256 = "0l9drc41nbaqd8wgxnq0wx4g5kjbzw11kmisah3rq2x9xv4girba";
  };
}

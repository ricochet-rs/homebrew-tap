class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "cae50ce26aec8bc84931b63df8d8cb2f87195d36815d97626c308c1f6a5db598"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v1.1.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "3dd326e8d17cf7ebecf9d6b70bb76b6b16bcd1cc97058dab5fe66c1ce59eccfc"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a88eb5b30245f1b348fff35fa3a907a45badb9e5fbbf4a03356579f96f04262a"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "677fe5dc635075cbed08072d92c05c913e60874923e06970c231d1fb0d6b63db"
    sha256 cellar: :any_skip_relocation, sequoia:       "1666eb8e61436eff62557960a1636c21ba4771f2e93869af6b4088cfddaabe99"
  end

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "9e168f013c50e81ab536088dc408c3cdc9b408b3",
        using: :git
  end

  depends_on "rust" => :build

  # Pass through environment for git auth (private dependencies)
  env :std

  def install
    # Stage the private dependency locally
    (buildpath/"deps/ricochet").install resource("ricochet-core")

    # Patch the git dependency to use local path
    File.open(buildpath/".cargo/config.toml", "a") do |f|
      f.puts <<~TOML

        [patch."https://github.com/ricochet-rs/ricochet"]
        ricochet-core = { path = "#{buildpath}/deps/ricochet/ricochet-core" }
      TOML
    end

    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "ricochet", shell_output("#{bin}/ricochet --help")
    system bin/"ricochet", "--version"
  end
end

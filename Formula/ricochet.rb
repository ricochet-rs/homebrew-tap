class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "f7482b5cf1eb31dda8e0a28434387d0132788d9cbf5d2ba42892bd6c12ced229"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v0.8.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "6df868e5bc2bb637adc8e0668278b2616e84c839d9639664339e1ece6ba04cc2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f41809447cb0c8109d683f15e3e45d2c96a2fef2ec010fb6687c7c2d15999e09"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2395cad537a0ceefe0ed86a4bb8367f38832c7ba22e63756451fb413800468cc"
    sha256 cellar: :any_skip_relocation, sequoia:       "d3c82e535dd7e6d8e782586222c6a06da4932e7378656d19c9976d65fec81cbd"
  end

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "60f13a2bd0e6242166d099cfa663b2c4903664d0",
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

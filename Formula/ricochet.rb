class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "3ec1b21dcfe8cbbfe19fdcfcecbcf0a8c9f9193938325851eae4b74461199a55"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "43facc1ef308432a09b200abff9d4d3a8777a239",
        using: :git
  end

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b80b07565977424f53e04a6b5a3e62f3a88007c362e4587156329338038b9356"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e5fc1467358ac47ed3cac3fbf52f4081116f426f81eff59436fd49e5ec34f726"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2b5f0c374945f961a748dedbae96b16a7bef3658d77ff1d5b9ca07023c61a83f"
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

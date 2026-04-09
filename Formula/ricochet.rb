class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v0.6.1.tar.gz"
  sha256 "6dd659e55c19fedf341da4017073cbe6a9126e2ca1312e2b0e3b161d737a2001"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v0.6.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "131cadc51c17b3999e24b17d52c2497eef560cc970d7ffe6adac3fbb6c172c13"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "69b055a24e65d3b1954f07cf6592a0363f8b36e9662531697328864613c83059"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "4183f29f5600d673851b63b3396813cd4024b34b5640963f62e43775db22db18"
    sha256 cellar: :any_skip_relocation, sequoia:       "22d62707c5f9eecc265f326b64e1846e8ff0b910746b240a5352c0dc136a8f59"
  end

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "a2d96c90e7ddaa79a9f8bdc72a88ba44781a8222",
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

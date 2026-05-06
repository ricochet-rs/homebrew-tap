class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "670c665b4cd802ab327fb7726dd06fdd9cae6cccac5f871b400d58f8fd640779"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v0.7.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "cfa6f7684237de71e02a5e0c86f9f4d54d37e8e203588fb00f55a23f73f0e95f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5a52a909852b85af4173bf32641f7f85d59b98c1ab307b4c7ed4a6bde56092dd"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "ba3c5d6772f5ac7522462191f54b89c4b75d2c6cded72296cdcb1feef09961e9"
    sha256 cellar: :any_skip_relocation, sequoia:       "b510f33b1d7fe20c8e0b36d2dd2c4dcbb046caf86a70077c4442cda03775bf1d"
  end

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "a3a31d09c75683674deb6d8ab269d844abc51380",
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

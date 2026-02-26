class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "66c132e15a75a47a2c89ab5da2d13a2a055d65f5c338bfd3b73353058ba911ec"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "949dfc49c9f3c717607487ddf9c1cb0840851b46",
        using: :git
  end

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v0.4.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "a24e16737f75a4d75376ebd29899f6907bccc7ca05fdb1b2232c3c5e3deea451"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "992dbc097d310b96581d1ef219744858af633e8a32f159debd5eda03c1b50fa3"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "23644ecda8a8c5448a521b327fb80fb4fb3a6b72b568a4c47062db68657265d7"
    sha256 cellar: :any_skip_relocation, sequoia:       "c90f6803aca1369ab27f46e70e57fc824cec26a465ccce8c42ca28f71932851a"
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

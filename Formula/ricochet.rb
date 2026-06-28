class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "92b75c4fe9c09b4672d52bb0c852f4391bb1889ac9c7f2520a174b270db12eec"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v0.8.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "8577aecd98c81b9b71f1c64170532ca95778cffee723f02fdf454432e29f6309"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "822b09d6ec28cd52a70b88528c750260ca6a4a7c42d7c1782531d743083858e8"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "9a2fda8f202f2628fd6cfb80585c95c8b47f828d0aab742cfccd4b555aabf489"
    sha256 cellar: :any_skip_relocation, sequoia:       "f40943aaba58c226ebda24a39e1deddb4f49ccbd503e4d8fad8e5af0c0d250f1"
  end

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "64e8faec8703595c3de5ca1f7e1c9f59b6e9e016",
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

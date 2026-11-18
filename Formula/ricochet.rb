class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v1.5.0.tar.gz"
  sha256 "ae372f41159c41844615d95c2e120832cac86a63e8389e281573cb9bdbb6a0cb"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v1.5.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c4d8b884fd1d4f048a5a442d62f6d891cb46baf1f8b1fc8a745d1f1af12f39e8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5ff30ef85b20c91d72ea6a8168aa7449ba39afc8b42ca7ae61753d711af2aa06"
  end

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "d6df36f8329c0e73d4d21cd7a6c567165fb7eec2",
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

class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v1.3.0.tar.gz"
  sha256 "864b4487833ee92c59168bde7112137b439fffa975d4eefc9be23bbb07190472"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v1.3.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f9cedaba29a8bf2b4ce35c2a7dbb6ef64e541503edc623517cbf1d239648d3c3"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c6c119398897eee7c0655f06de548e06939c39a51583afc2934844c1c5c77f8f"
  end

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "5324123d05be9f1e89c121d7ae446ce037c0f8c7",
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

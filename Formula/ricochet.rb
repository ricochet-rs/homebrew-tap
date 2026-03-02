class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "66c132e15a75a47a2c89ab5da2d13a2a055d65f5c338bfd3b73353058ba911ec"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v0.4.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "2aec77b3bb0737e0552de1bc14933e634d332c3eb37ba3069ca5bb859e38249e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "eccfe2f7eea2940a501884754be92647766137b10f940fd8cd208e671c94532d"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "aa750819572ea2565a9fbf0f689e84b9c3f974e1da68313800b745e9f32498b4"
    sha256 cellar: :any_skip_relocation, sequoia:       "b4e8f878b74b18e572f0ba249e163493ca99da9c87fdac0511c4d6ecebd943af"
  end

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "949dfc49c9f3c717607487ddf9c1cb0840851b46",
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

class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "bf6519bfab9169232b347ba74bb83624eed10884ca241437f90eee026149953c"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v1.2.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "20a1f6c02820150495e5f8474a4b61f4b41afcc7c7df01d3e7f0521cc0409a01"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0fa86efd382a854e3d84c950035997a3c7946f7f0bf4f74d663ade6be21d8271"
  end

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "0e9fb2ca88f7ef291b4cbde7a62cceb83240124f",
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

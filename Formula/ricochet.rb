class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "f7482b5cf1eb31dda8e0a28434387d0132788d9cbf5d2ba42892bd6c12ced229"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v0.7.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "2e5c697cb01a3fdb726da5bd06b1e51bbdbebc9b2a6977780b690442b0f0359f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "eaef52b61736b6a264c96a29adec3268f335ed38d3eec67eb86f58e08eef1024"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "db9ef54757e2b52e8b9c41a56ff84244bc3ebe44ab7d2bd85862ad810f33a928"
    sha256 cellar: :any_skip_relocation, sequoia:       "258a260461d1e192b9dbc22ad3075e37fa4ba54a2a2910c3f06daef6021d697d"
  end

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "d6573e73c734d401890217116e24fbf77edcae52",
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

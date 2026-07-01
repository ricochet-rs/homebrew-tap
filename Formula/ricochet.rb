class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "f2b357c776492ae76adcf8fdd1da2604ea305a9c5b2d166a51b5ba78fd8a8d11"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v0.8.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "a2941e6701882f46c76bd05ad532c9b5fdc018126bc5708d92fa5b80801ec484"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9af1ff3e00b82b6e859e198c08dd269da9d462d43a111bcdbb582f79cda34568"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "40b638d90d7ab63e55a979bb866fe822aaab99899bdbfbce4fe30c89cc71423e"
    sha256 cellar: :any_skip_relocation, sequoia:       "93c4f2db598b020b011e8300ee385b20aa586de584eaaf0b6651dcaeac440686"
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

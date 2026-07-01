class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "f2b357c776492ae76adcf8fdd1da2604ea305a9c5b2d166a51b5ba78fd8a8d11"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v1.0.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c09d22394ca74030f8608e0c3073895638540dee2baf60b4f11af0d9632a6fc6"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d0c52f2a932b5140c863b601f708944264151a8cfd3542609504726ad4f852bd"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "0ead89a181f6d843cb8c20092306df2568937c0efce8b0021c20e1ced156fd0a"
    sha256 cellar: :any_skip_relocation, sequoia:       "e87aa902e554fb30a75a6b73a76158051ae7de8a891758812a061dc9d6727d94"
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

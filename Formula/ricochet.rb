class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "637bcf6d9e7ff7863eecc6251ab960a1f3d7a4d324845761bee0d33b543e99ae"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "949dfc49c9f3c717607487ddf9c1cb0840851b46",
        using: :git
  end

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "861fe97359feb0c8ec670aec96177dc60e3395e341b31ad37ce060cf63edc3df"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ec586c77a21945c603eee9a324b131d03b605f50a2a600f4f1c647451fe907df"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2cb38765d2b99c8f648034f8f630dda1dfe5fffaf94dd57dd8e5fca188044153"
    sha256 cellar: :any_skip_relocation, sequoia:       "3f359d7cbeeca6df915c9a8980823982d5ad4ebd8c9a0fccce09aac1a67a4744"
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

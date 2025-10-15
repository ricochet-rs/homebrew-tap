class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "6a1cb7ead8f2ee0f076c8afc3307cde3d878f206d9aa1fcbffa6d57bfa65f52d"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v0.1.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9e20a395e1010a85eee2f6d9b9ffc9d590d5067b8ba00b85c590a589b081277e"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "ricochet", shell_output("#{bin}/ricochet --help")
    system bin/"ricochet", "--version"
  end
end

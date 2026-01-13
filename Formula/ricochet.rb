class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "6f0ccea8f3956f98a13b1aed47fcca61d012c0ee3ecb6b6e4a9123e0153eafaf"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v0.1.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d740615aac9ebc23ebfef9e787a98cab287c20da7810e5dab288759a97a534bf"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "7770b9fd46d9e8a9771d9ade32d796b804f12ea15a6314dd9d1c57594391d963"
    sha256 cellar: :any_skip_relocation, sequoia:       "dc77b16cef04443ea4c8b6390fc6c7fe9b5f53a4680c519fa0af82fdbc45e470"
  end

  depends_on "rust" => :build

  # Pass through environment for git auth (private dependencies)
  env :std

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "ricochet", shell_output("#{bin}/ricochet --help")
    system bin/"ricochet", "--version"
  end
end

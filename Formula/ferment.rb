# frozen_string_literal: true

# Homebrew formula for ferment.
#
# This formula lives in the main ferment repository (single-repo layout).
# Users install it like this (note the explicit tap URL on first run, since
# the repo is not named "homebrew-..."):
#
#   brew tap mei28/ferment https://github.com/mei28/ferment.git
#   brew install ferment
#
# Subsequent updates are picked up with the usual `brew update && brew upgrade`.
class Ferment < Formula
  desc "Thin Mutagen wrapper that ferments your file changes"
  homepage "https://github.com/mei28/ferment"
  url "https://github.com/mei28/ferment/archive/refs/tags/v0.1.0.tar.gz"
  # The sha256 below is updated automatically by .github/workflows/release.yml
  # whenever a v* tag is pushed.
  sha256 "REPLACE_ME_WITH_TARBALL_SHA256"
  license "MIT"
  head "https://github.com/mei28/ferment.git", branch: "main"

  # Hard dependency: ferment is a wrapper around mutagen.
  depends_on "mutagen-io/mutagen/mutagen"

  def install
    bin.install "bin/ferment"

    bash_completion.install "completions/ferment.bash" => "ferment" if File.exist?("completions/ferment.bash")
    zsh_completion.install  "completions/_ferment"                  if File.exist?("completions/_ferment")
    fish_completion.install "completions/ferment.fish"              if File.exist?("completions/ferment.fish")

    doc.install "README.md"      if File.exist?("README.md")
    doc.install "README.ja.md"   if File.exist?("README.ja.md")
  end

  test do
    assert_match "ferment", shell_output("#{bin}/ferment version")
    # init should produce a project file
    Dir.mktmpdir do |dir|
      cd dir do
        # mutagen is on PATH (declared dependency)
        system bin/"ferment", "init", "test-proj"
        assert_predicate Pathname.new("mutagen.yml"), :exist?
      end
    end
  end
end

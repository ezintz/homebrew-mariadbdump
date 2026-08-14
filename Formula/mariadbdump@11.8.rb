class MariadbdumpAT118 < Formula
  desc "Standalone mariadb-dump (mysqldump-compatible) client, MariaDB 11.8"
  homepage "https://mariadb.org/"
  url "https://archive.mariadb.org/mariadb-11.8.8/source/mariadb-11.8.8.tar.gz"
  sha256 "bd023a4959faf012db7f0ebfc0d276729e67e5443df193163f98d80fdfc524c9"
  license "GPL-2.0-only"

  keg_only :versioned_formula

  depends_on "bison" => :build
  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "openssl@3"
  depends_on "zstd"

  def install
    args = std_cmake_args + %w[
      -DWITHOUT_SERVER=ON
      -DWITH_UNIT_TESTS=OFF
      -DCOMPILATION_COMMENT=Homebrew-Standalone
    ]

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build", "--target", "mariadb-dump"

    bin.install "build/client/mariadb-dump"
    bin.install_symlink "mariadb-dump" => "mysqldump"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mariadb-dump --version")
  end
end

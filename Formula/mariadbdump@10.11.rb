class MariadbdumpAT1011 < Formula
  desc "Standalone mariadb-dump (mysqldump-compatible) client, MariaDB 10.11"
  homepage "https://mariadb.org/"
  url "https://archive.mariadb.org/mariadb-10.11.18/source/mariadb-10.11.18.tar.gz"
  sha256 "a46852c68075be7c31c7b33fee233c5b5a00c8c28117f5204d124e4f2fd56fa8"
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

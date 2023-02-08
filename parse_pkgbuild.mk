# TODO: Simplify all of these with sed.
pkgname = $$(grep 'pkgname=' $1 | grep -oE "[0-9a-zA-Z_-]+" | grep -v pkgname)
pkgver = $$(grep 'pkgver=' $1 | grep -oE "[0-9a-zA-Z_.-]+" | grep -v pkgver)
pkgrel = $$(grep 'pkgrel=' $1 | grep -oE "[0-9]+" | grep -v pkgrel)
arch = $$(grep 'arch=' $1 | grep -oE "[0-9a-zA-Z_-]+" | grep -v arch)

package_filename = $(pkgname)-$(pkgver)-$(pkgrel)-$(arch).pkg.tar.zst

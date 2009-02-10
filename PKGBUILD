
# See http://wiki.archlinux.org/index.php/Arch_CVS_&_SVN_PKGBUILD_guidelines
# for more information on packaging from GIT sources.

# Contributor: Joël Schaerer <joel.schaerer@laposte.net>
pkgname=autojump
pkgver=VERSION
pkgrel=1
pkgdesc="A faster way to navigate your filesystem from the command line"
arch=(i686)
url="http://wiki.github.com/joelthelion/autojump"
license=('GPL')
depends=('bash' 'python')
md5sums=() #generate with 'makepkg -g'

_gitroot="git://github.com/joelthelion/autojump.git"
_gitname="autojump"

build() {
  cd "$srcdir"
  msg "Connecting to GIT server...."

  if [ -d $_gitname ] ; then
    cd $_gitname && git pull origin || return 1
    msg "The local files are updated."
  else
    git clone $_gitroot || return 1
  fi

  msg "GIT checkout done"
  install -Dm 755 autojump ${pkgdir}/usr/bin/autojump
  install -Dm 755 autojump.sh ${pkgdir}/etc/profile.d/autojump.sh
} 

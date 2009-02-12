# Contributor: Joël Schaerer <joel.schaerer@laposte.net>
pkgname=autojump
pkgver=20090210
pkgrel=2
pkgdesc="A faster way to navigate your filesystem from the command line"
arch=(i686 x86_64)
url="http://wiki.github.com/joelthelion/autojump"
license=('GPL')
depends=('bash' 'python')
md5sums=() #generate with 'makepkg -g'
install=(autojump.install)

_gitroot="git://github.com/joelthelion/autojump.git"
_gitname="autojump"

build() {
  cd "$srcdir"
  msg "Connecting to GIT server...."

  if [ -d $_gitname ] ; then
    cd $_gitname && git pull origin || return 1
    msg "The local files are updated."
  else
    git clone $_gitroot && cd $_gitname || return 1
  fi
  gzip -f autojump.1

  msg "GIT checkout done"
  install -Dm 755 autojump ${pkgdir}/usr/bin/autojump
  install -Dm 755 autojump.sh ${pkgdir}/etc/profile.d/autojump.sh
  install -Dm 644 autojump.1.gz ${pkgdir}/usr/share/man/man1/autojump.1.gz
} 

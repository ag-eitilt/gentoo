# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit qmake-utils vcs-snapshot

DESCRIPTION="Signon daemon for libaccounts-glib"
HOMEPAGE="https://01.org/gsso/"
SRC_URI="https://gitlab.com/accounts-sso/${PN}/-/archive/VERSION_${PV}/${PN}-VERSION_${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="doc test"

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtsql:5
	net-libs/libproxy
"
DEPEND="${RDEPEND}
	test? ( dev-qt/qttest:5 )
"
BDEPEND="doc? ( app-doc/doxygen )"

src_prepare() {
	default

	# remove unused dependency
	sed -e "/xml \\\/d" -i src/signond/signond.pro || die

	# install docs to correct location
	sed -e "s|share/doc/\$\${PROJECT_NAME}|share/doc/${PF}|" -i doc/doc.pri || die
	sed -e "/^documentation.path = /c\documentation.path = \$\${INSTALL_PREFIX}/share/doc/${PF}/\$\${TARGET}/" \
		-i lib/plugins/doc/doc.pri || die
	sed -e "/^documentation.path = /c\documentation.path = \$\${INSTALL_PREFIX}/share/doc/${PF}/libsignon-qt/" \
		-i lib/SignOn/doc/doc.pri || die

	# don't install example plugin
	sed -e "/example/d" -i src/plugins/plugins.pro || die

	# don't install static libs
	sed -e "/libsignon-qt-static.pro/s/^/#/" -i lib/SignOn/SignOn.pro || die

	# make tests optional
	use test || sed -i -e '/^SUBDIRS/s/tests//' signon.pro || die "couldn't disable tests"

	# make docs optional
	use doc || sed -e "/include(\s*doc\/doc.pri\s*)/d" -i \
		signon.pro -i lib/SignOn/SignOn.pro lib/plugins/plugins.pro || die
}

src_configure() {
	eqmake5 LIBDIR=/usr/$(get_libdir)
}

src_install() {
	emake INSTALL_ROOT="${D}" install
}

# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Jay Kominek's database of the elements for dict"
HOMEPAGE="http://www.dict.org"
SRC_FILE="https://web.archive.org/web/20121223051336/http://www.miranda.org:80/~jkominek/elements/elements.db"
SRC_URI="${SRC_FILE} -> ${P}.db"

LICENSE="public-domain"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"

DEPEND=">=app-text/dictd-1.5.5"

S="${WORKDIR}"

src_unpack() {
	cp "${DISTDIR}/${A}" elements.db || die
}

src_prepare() {
	eapply_user
	sed -f "${FILESDIR}/prepare.sed" -i elements.db || die
}

src_compile() {
	(dictfmt -u "${SRC_FILE}" \
		-s "Jay Kominek's Elements database (version ${PV})" \
		--headword-separator " " \
		--columns 80 \
		-p elements \
		|| die) \
		< elements.db
	dictzip elements.dict || die
}

src_install() {
	insinto /usr/lib/dict
	doins elements.dict.dz elements.index
}

pkg_postinst() {
	if [[ "${REPLACING_VERSIONS}" ]] ; then
		elog "You must restart your dictd server before the ${PN} dictionary is"
		elog "completely updated.  If you are using OpenRC, this may be accomplished by"
		elog "running '/etc/init.d/dictd restart'."
	else
		elog "You must register ${PN} and restart your dictd server before the"
		elog "dictionary is available for use.  If you are using OpenRC, both tasks may be"
		elog "accomplished by running '/etc/init.d/dictd restart'."
	fi
}

pkg_postrm() {
	if [[ ! "${REPLACED_BY_VERSION}" ]] ; then
		elog "You must unregister ${PN} and restart your dictd server before the"
		elog "dictionary is completely removed.  If you are using OpenRC, both tasks may be"
		elog "accomplished by running '/etc/init.d/dictd restart'."
	fi
}

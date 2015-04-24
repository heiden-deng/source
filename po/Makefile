# Makefile for PO directory in any package using GNU gettext.
# Copyright (C) 1995-1997, 2000-2007 by Ulrich Drepper <drepper@gnu.ai.mit.edu>
#
# This file can be copied and used freely without restrictions.  It can
# be used in projects which are not available under the GNU General Public
# License but which still want to provide support for the GNU gettext
# functionality.
# Please note that the actual code of GNU gettext is covered by the GNU
# General Public License and is *not* in the public domain.
#
# Origin: gettext-0.17
GETTEXT_MACRO_VERSION = 0.17

PACKAGE = anaconda
VERSION = 13.21.229
PACKAGE_BUGREPORT = anaconda-devel-list@redhat.com

SHELL = /bin/sh


srcdir = .
top_srcdir = ..


prefix = /usr/local/anaconda
exec_prefix = ${prefix}
datarootdir = ${prefix}/share
datadir = ${datarootdir}
localedir = ${datarootdir}/locale
gettextsrcdir = $(datadir)/gettext/po

INSTALL = /usr/bin/install -c
INSTALL_DATA = ${INSTALL} -m 644

# We use $(mkdir_p).
# In automake <= 1.9.x, $(mkdir_p) is defined either as "mkdir -p --" or as
# "$(mkinstalldirs)" or as "$(install_sh) -d". For these automake versions,
# ${SHELL} /home/dengjq/software/anaconda-sugon/install-sh does not start with $(SHELL), so we add it.
# In automake >= 1.10, /bin/mkdir -p is derived from ${MKDIR_P}, which is defined
# either as "/path/to/mkdir -p" or ".../install-sh -c -d". For these automake
# versions, $(mkinstalldirs) and $(install_sh) are unused.
mkinstalldirs = $(SHELL) ${SHELL} /home/dengjq/software/anaconda-sugon/install-sh -d
install_sh = $(SHELL) ${SHELL} /home/dengjq/software/anaconda-sugon/install-sh
MKDIR_P = /bin/mkdir -p
mkdir_p = /bin/mkdir -p

GMSGFMT_ = /usr/bin/msgfmt
GMSGFMT_no = /usr/bin/msgfmt
GMSGFMT_yes = /usr/bin/msgfmt
GMSGFMT = $(GMSGFMT_$(USE_MSGCTXT))
MSGFMT_ = /usr/bin/msgfmt
MSGFMT_no = /usr/bin/msgfmt
MSGFMT_yes = /usr/bin/msgfmt
MSGFMT = $(MSGFMT_$(USE_MSGCTXT))
XGETTEXT_ = /usr/bin/xgettext
XGETTEXT_no = /usr/bin/xgettext
XGETTEXT_yes = /usr/bin/xgettext
XGETTEXT = $(XGETTEXT_$(USE_MSGCTXT))
MSGMERGE = msgmerge
MSGMERGE_UPDATE = /usr/bin/msgmerge --update
MSGINIT = msginit
MSGCONV = msgconv
MSGFILTER = msgfilter

POFILES =  af.po am.po ar.po as.po bal.po be.po bg.po bn.po bn_IN.po bs.po ca.po cs.po cy.po da.po de.po de_CH.po el.po en@quot.po en@boldquot.po en_GB.po es.po et.po eu.po fa.po fi.po fr.po gl.po gu.po he.po hi.po hr.po hu.po hy.po id.po ilo.po is.po it.po ja.po ka.po kn.po ko.po lt.po lv.po mai.po mk.po ml.po mr.po ms.po nb.po ne.po nl.po nn.po nso.po or.po pa.po pl.po pt.po pt_BR.po ro.po ru.po si.po sk.po sl.po sq.po sr.po sr@latin.po sv.po ta.po te.po tg.po th.po tr.po uk.po ur.po vi.po zh_CN.po zh_TW.po zu.po
GMOFILES =  af.gmo am.gmo ar.gmo as.gmo bal.gmo be.gmo bg.gmo bn.gmo bn_IN.gmo bs.gmo ca.gmo cs.gmo cy.gmo da.gmo de.gmo de_CH.gmo el.gmo en@quot.gmo en@boldquot.gmo en_GB.gmo es.gmo et.gmo eu.gmo fa.gmo fi.gmo fr.gmo gl.gmo gu.gmo he.gmo hi.gmo hr.gmo hu.gmo hy.gmo id.gmo ilo.gmo is.gmo it.gmo ja.gmo ka.gmo kn.gmo ko.gmo lt.gmo lv.gmo mai.gmo mk.gmo ml.gmo mr.gmo ms.gmo nb.gmo ne.gmo nl.gmo nn.gmo nso.gmo or.gmo pa.gmo pl.gmo pt.gmo pt_BR.gmo ro.gmo ru.gmo si.gmo sk.gmo sl.gmo sq.gmo sr.gmo sr@latin.gmo sv.gmo ta.gmo te.gmo tg.gmo th.gmo tr.gmo uk.gmo ur.gmo vi.gmo zh_CN.gmo zh_TW.gmo zu.gmo
UPDATEPOFILES =  af.po-update am.po-update ar.po-update as.po-update bal.po-update be.po-update bg.po-update bn.po-update bn_IN.po-update bs.po-update ca.po-update cs.po-update cy.po-update da.po-update de.po-update de_CH.po-update el.po-update en@quot.po-update en@boldquot.po-update en_GB.po-update es.po-update et.po-update eu.po-update fa.po-update fi.po-update fr.po-update gl.po-update gu.po-update he.po-update hi.po-update hr.po-update hu.po-update hy.po-update id.po-update ilo.po-update is.po-update it.po-update ja.po-update ka.po-update kn.po-update ko.po-update lt.po-update lv.po-update mai.po-update mk.po-update ml.po-update mr.po-update ms.po-update nb.po-update ne.po-update nl.po-update nn.po-update nso.po-update or.po-update pa.po-update pl.po-update pt.po-update pt_BR.po-update ro.po-update ru.po-update si.po-update sk.po-update sl.po-update sq.po-update sr.po-update sr@latin.po-update sv.po-update ta.po-update te.po-update tg.po-update th.po-update tr.po-update uk.po-update ur.po-update vi.po-update zh_CN.po-update zh_TW.po-update zu.po-update
DUMMYPOFILES =  af.nop am.nop ar.nop as.nop bal.nop be.nop bg.nop bn.nop bn_IN.nop bs.nop ca.nop cs.nop cy.nop da.nop de.nop de_CH.nop el.nop en@quot.nop en@boldquot.nop en_GB.nop es.nop et.nop eu.nop fa.nop fi.nop fr.nop gl.nop gu.nop he.nop hi.nop hr.nop hu.nop hy.nop id.nop ilo.nop is.nop it.nop ja.nop ka.nop kn.nop ko.nop lt.nop lv.nop mai.nop mk.nop ml.nop mr.nop ms.nop nb.nop ne.nop nl.nop nn.nop nso.nop or.nop pa.nop pl.nop pt.nop pt_BR.nop ro.nop ru.nop si.nop sk.nop sl.nop sq.nop sr.nop sr@latin.nop sv.nop ta.nop te.nop tg.nop th.nop tr.nop uk.nop ur.nop vi.nop zh_CN.nop zh_TW.nop zu.nop
DISTFILES.common = Makefile.in.in remove-potcdate.sin \
$(DISTFILES.common.extra1) $(DISTFILES.common.extra2) $(DISTFILES.common.extra3)
DISTFILES = $(DISTFILES.common) Makevars POTFILES.in \
$(POFILES) $(GMOFILES) \
$(DISTFILES.extra1) $(DISTFILES.extra2) $(DISTFILES.extra3)

POTFILES = \
     ../anaconda \
     ../backend.py \
     ../bootloader.py \
     ../cmdline.py \
     ../compssort.py \
     ../constants.py \
     ../firewall.py \
     ../gui.py \
     ../image.py \
     ../installclass.py \
     ../installinterfacebase.py \
     ../instdata.py \
     ../iutil.py \
     ../kickstart.py \
     ../livecd.py \
     ../network.py \
     ../packages.py \
     ../partIntfHelpers.py \
     ../platform.py \
     ../rescue.py \
     ../text.py \
     ../upgrade.py \
     ../vnc.py \
     ../yuminstall.py \
     ../installclasses/fedora.py \
     ../installclasses/rhel.py \
     ../iw/DeviceSelector.py \
     ../iw/GroupSelector.py \
     ../iw/account_gui.py \
     ../iw/advanced_storage.py \
     ../iw/autopart_type.py \
     ../iw/blpasswidget.py \
     ../iw/bootloader_main_gui.py \
     ../iw/checklist.py \
     ../iw/cleardisks_gui.py \
     ../iw/congrats_gui.py \
     ../iw/datacombo.py \
     ../iw/examine_gui.py \
     ../iw/filter_gui.py \
     ../iw/filter_type.py \
     ../iw/iw_gui.py \
     ../iw/language_gui.py \
     ../iw/lvm_dialog_gui.py \
     ../iw/network_gui.py \
     ../iw/osbootwidget.py \
     ../iw/package_gui.py \
     ../iw/partition_dialog_gui.py \
     ../iw/partition_gui.py \
     ../iw/partition_ui_helpers_gui.py \
     ../iw/pixmapRadioButtonGroup_gui.py \
     ../iw/raid_dialog_gui.py \
     ../iw/task_gui.py \
     ../iw/timezone_gui.py \
     ../iw/upgrade_bootloader_gui.py \
     ../iw/upgrade_migratefs_gui.py \
     ../iw/upgrade_swap_gui.py \
     ../iw/welcome_gui.py \
     ../iw/zipl_gui.py \
     ../loader/cdinstall.h \
     ../loader/copy.h \
     ../loader/dirbrowser.h \
     ../loader/driverdisk.h \
     ../loader/hdinstall.h \
     ../loader/kbd.h \
     ../loader/kickstart.h \
     ../loader/lang.h \
     ../loader/loader.h \
     ../loader/mediacheck.h \
     ../loader/method.h \
     ../loader/modules.h \
     ../loader/net.h \
     ../loader/nfsinstall.h \
     ../loader/telnetd.h \
     ../loader/urlinstall.h \
     ../loader/urls.h \
     ../loader/windows.h \
     ../loader/cdinstall.c \
     ../loader/copy.c \
     ../loader/dirbrowser.c \
     ../loader/driverdisk.c \
     ../loader/driverselect.c \
     ../loader/hdinstall.c \
     ../loader/kbd.c \
     ../loader/kickstart.c \
     ../loader/lang.c \
     ../loader/loader.c \
     ../loader/mediacheck.c \
     ../loader/method.c \
     ../loader/modules.c \
     ../loader/net.c \
     ../loader/nfsinstall.c \
     ../loader/telnetd.c \
     ../loader/urlinstall.c \
     ../loader/urls.c \
     ../loader/windows.c \
     ../storage/__init__.py \
     ../storage/dasd.py \
     ../storage/deviceaction.py \
     ../storage/devicelibs/crypto.py \
     ../storage/devicelibs/dm.py \
     ../storage/devicelibs/lvm.py \
     ../storage/devicelibs/mdraid.py \
     ../storage/devicelibs/swap.py \
     ../storage/devices.py \
     ../storage/devicetree.py \
     ../storage/fcoe.py \
     ../storage/formats/__init__.py \
     ../storage/formats/disklabel.py \
     ../storage/formats/dmraid.py \
     ../storage/formats/fs.py \
     ../storage/formats/luks.py \
     ../storage/formats/lvmpv.py \
     ../storage/formats/mdraid.py \
     ../storage/formats/multipath.py \
     ../storage/formats/swap.py \
     ../storage/iscsi.py \
     ../storage/partitioning.py \
     ../storage/zfcp.py \
     ../textw/complete_text.py \
     ../textw/constants_text.py \
     ../textw/keyboard_text.py \
     ../textw/language_text.py \
     ../textw/netconfig_text.py \
     ../textw/partition_text.py \
     ../textw/progress_text.py \
     ../textw/timezone_text.py \
     ../textw/upgrade_bootloader_text.py \
     ../textw/upgrade_text.py \
     ../textw/userauth_text.py \
     ../textw/welcome_text.py \
     ../textw/zipl_text.py \
     ../liveinst/liveinst.desktop.in.h \
     ../ui/GroupSelector.glade.h \
     ../ui/account.glade.h \
     ../ui/adddrive.glade.h \
     ../ui/addrepo.glade.h \
     ../ui/anaconda.glade.h \
     ../ui/autopart.glade.h \
     ../ui/blwhere.glade.h \
     ../ui/cleardisks.glade.h \
     ../ui/create-storage.glade.h \
     ../ui/detailed-dialog.glade.h \
     ../ui/device-options.glade.h \
     ../ui/fcoe-config.glade.h \
     ../ui/filter.glade.h \
     ../ui/iscsi-dialogs.glade.h \
     ../ui/lukspassphrase.glade.h \
     ../ui/network.glade.h \
     ../ui/tasksel.glade.h \
     ../ui/zfcp-config.glade.h \
     ../ui/reinitialize-dialog.glade.h \
     ../lang-table.h

CATALOGS =  af.gmo am.gmo ar.gmo as.gmo bal.gmo be.gmo bg.gmo bn.gmo bn_IN.gmo bs.gmo ca.gmo cs.gmo cy.gmo da.gmo de.gmo de_CH.gmo el.gmo en@quot.gmo en@boldquot.gmo en_GB.gmo es.gmo et.gmo eu.gmo fa.gmo fi.gmo fr.gmo gl.gmo gu.gmo he.gmo hi.gmo hr.gmo hu.gmo hy.gmo id.gmo ilo.gmo is.gmo it.gmo ja.gmo ka.gmo kn.gmo ko.gmo lt.gmo lv.gmo mai.gmo mk.gmo ml.gmo mr.gmo ms.gmo nb.gmo ne.gmo nl.gmo nn.gmo nso.gmo or.gmo pa.gmo pl.gmo pt.gmo pt_BR.gmo ro.gmo ru.gmo si.gmo sk.gmo sl.gmo sq.gmo sr.gmo sr@latin.gmo sv.gmo ta.gmo te.gmo tg.gmo th.gmo tr.gmo uk.gmo ur.gmo vi.gmo zh_CN.gmo zh_TW.gmo zu.gmo

# Makevars gets inserted here. (Don't remove this line!)
# Makefile variables for PO directory in any package using GNU gettext.

# Usually the message domain is the same as the package name.
DOMAIN = $(PACKAGE)

# These two variables depend on the location of this directory.
subdir = po
top_builddir = ..

# These options get passed to xgettext.
XGETTEXT_OPTIONS = --keyword=_ --keyword=N_ --keyword=P_:1,2 --from-code=UTF-8

# This is the copyright holder that gets inserted into the header of the
# $(DOMAIN).pot file.  Set this to the copyright holder of the surrounding
# package.  (Note that the msgstr strings, extracted from the package's
# sources, belong to the copyright holder of the package.)  Translators are
# expected to transfer the copyright for their translations to this person
# or entity, or to disclaim their copyright.  The empty string stands for
# the public domain; in this case the translators are expected to disclaim
# their copyright.
COPYRIGHT_HOLDER = Red Hat, Inc.

# This is the email address or URL to which the translators shall report
# bugs in the untranslated strings:
# - Strings which are not entire sentences, see the maintainer guidelines
#   in the GNU gettext documentation, section 'Preparing Strings'.
# - Strings which use unclear terms or require additional context to be
#   understood.
# - Strings which make invalid assumptions about notation of date, time or
#   money.
# - Pluralisation problems.
# - Incorrect English spelling.
# - Incorrect formatting.
# It can be your email address, or a mailing list address where translators
# can write to without being subscribed, or the URL of a web page through
# which the translators can contact you.
MSGID_BUGS_ADDRESS = anaconda-devel-list@redhat.com

# This is the list of locale categories, beyond LC_MESSAGES, for which the
# message catalogs shall be used.  It is usually empty.
EXTRA_LOCALE_CATEGORIES =

.SUFFIXES:
.SUFFIXES: .po .gmo .mo .sed .sin .nop .po-create .po-update

.po.mo:
	@echo "$(MSGFMT) -c -o $@ $<"; \
	$(MSGFMT) -c -o t-$@ $< && mv t-$@ $@

.po.gmo:
	@lang=`echo $* | sed -e 's,.*/,,'`; \
	test "$(srcdir)" = . && cdcmd="" || cdcmd="cd $(srcdir) && "; \
	echo "$${cdcmd}rm -f $${lang}.gmo && $(GMSGFMT) -c --statistics -o $${lang}.gmo $${lang}.po"; \
	cd $(srcdir) && rm -f $${lang}.gmo && $(GMSGFMT) -c --statistics -o t-$${lang}.gmo $${lang}.po && mv t-$${lang}.gmo $${lang}.gmo

.sin.sed:
	sed -e '/^#/d' $< > t-$@
	mv t-$@ $@


all: check-macro-version all-yes

all-yes: stamp-po
all-no:

# Ensure that the gettext macros and this Makefile.in.in are in sync.
check-macro-version:
	@test "$(GETTEXT_MACRO_VERSION)" = "0.17" \
	  || { echo "*** error: gettext infrastructure mismatch: using a Makefile.in.in from gettext version $(GETTEXT_MACRO_VERSION) but the autoconf macros are from gettext version 0.17" 1>&2; \
	       exit 1; \
	     }

# $(srcdir)/$(DOMAIN).pot is only created when needed. When xgettext finds no
# internationalized messages, no $(srcdir)/$(DOMAIN).pot is created (because
# we don't want to bother translators with empty POT files). We assume that
# LINGUAS is empty in this case, i.e. $(POFILES) and $(GMOFILES) are empty.
# In this case, stamp-po is a nop (i.e. a phony target).

# stamp-po is a timestamp denoting the last time at which the CATALOGS have
# been loosely updated. Its purpose is that when a developer or translator
# checks out the package via CVS, and the $(DOMAIN).pot file is not in CVS,
# "make" will update the $(DOMAIN).pot and the $(CATALOGS), but subsequent
# invocations of "make" will do nothing. This timestamp would not be necessary
# if updating the $(CATALOGS) would always touch them; however, the rule for
# $(POFILES) has been designed to not touch files that don't need to be
# changed.
stamp-po: $(srcdir)/$(DOMAIN).pot
	test ! -f $(srcdir)/$(DOMAIN).pot || \
	  test -z "$(GMOFILES)" || $(MAKE) $(GMOFILES)
	@test ! -f $(srcdir)/$(DOMAIN).pot || { \
	  echo "touch stamp-po" && \
	  echo timestamp > stamp-poT && \
	  mv stamp-poT stamp-po; \
	}

# Note: Target 'all' must not depend on target '$(DOMAIN).pot-update',
# otherwise packages like GCC can not be built if only parts of the source
# have been downloaded.

# This target rebuilds $(DOMAIN).pot; it is an expensive operation.
# Note that $(DOMAIN).pot is not touched if it doesn't need to be changed.
$(DOMAIN).pot-update: $(POTFILES) $(srcdir)/POTFILES.in remove-potcdate.sed
	if LC_ALL=C grep 'GNU anaconda' $(top_srcdir)/* 2>/dev/null | grep -v 'libtool:' >/dev/null; then \
	  package_gnu='GNU '; \
	else \
	  package_gnu=''; \
	fi; \
	if test -n '$(MSGID_BUGS_ADDRESS)' || test '$(PACKAGE_BUGREPORT)' = '@'PACKAGE_BUGREPORT'@'; then \
	  msgid_bugs_address='$(MSGID_BUGS_ADDRESS)'; \
	else \
	  msgid_bugs_address='$(PACKAGE_BUGREPORT)'; \
	fi; \
	case `$(XGETTEXT) --version | sed 1q | sed -e 's,^[^0-9]*,,'` in \
	  '' | 0.[0-9] | 0.[0-9].* | 0.1[0-5] | 0.1[0-5].* | 0.16 | 0.16.[0-1]*) \
	    $(XGETTEXT) --default-domain=$(DOMAIN) --directory=$(top_srcdir) \
	      --add-comments=TRANSLATORS: $(XGETTEXT_OPTIONS)  \
	      --files-from=$(srcdir)/POTFILES.in \
	      --copyright-holder='$(COPYRIGHT_HOLDER)' \
	      --msgid-bugs-address="$$msgid_bugs_address" \
	    ;; \
	  *) \
	    $(XGETTEXT) --default-domain=$(DOMAIN) --directory=$(top_srcdir) \
	      --add-comments=TRANSLATORS: $(XGETTEXT_OPTIONS)  \
	      --files-from=$(srcdir)/POTFILES.in \
	      --copyright-holder='$(COPYRIGHT_HOLDER)' \
	      --package-name="$${package_gnu}anaconda" \
	      --package-version='13.21.229' \
	      --msgid-bugs-address="$$msgid_bugs_address" \
	    ;; \
	esac
	test ! -f $(DOMAIN).po || { \
	  if test -f $(srcdir)/$(DOMAIN).pot; then \
	    sed -f remove-potcdate.sed < $(srcdir)/$(DOMAIN).pot > $(DOMAIN).1po && \
	    sed -f remove-potcdate.sed < $(DOMAIN).po > $(DOMAIN).2po && \
	    if cmp $(DOMAIN).1po $(DOMAIN).2po >/dev/null 2>&1; then \
	      rm -f $(DOMAIN).1po $(DOMAIN).2po $(DOMAIN).po; \
	    else \
	      rm -f $(DOMAIN).1po $(DOMAIN).2po $(srcdir)/$(DOMAIN).pot && \
	      mv $(DOMAIN).po $(srcdir)/$(DOMAIN).pot; \
	    fi; \
	  else \
	    mv $(DOMAIN).po $(srcdir)/$(DOMAIN).pot; \
	  fi; \
	}

# This rule has no dependencies: we don't need to update $(DOMAIN).pot at
# every "make" invocation, only create it when it is missing.
# Only "make $(DOMAIN).pot-update" or "make dist" will force an update.
$(srcdir)/$(DOMAIN).pot:
	$(MAKE) $(DOMAIN).pot-update

# This target rebuilds a PO file if $(DOMAIN).pot has changed.
# Note that a PO file is not touched if it doesn't need to be changed.
$(POFILES): $(srcdir)/$(DOMAIN).pot
	@lang=`echo $@ | sed -e 's,.*/,,' -e 's/\.po$$//'`; \
	if test -f "$(srcdir)/$${lang}.po"; then \
	  test "$(srcdir)" = . && cdcmd="" || cdcmd="cd $(srcdir) && "; \
	  echo "$${cdcmd}$(MSGMERGE_UPDATE) $${lang}.po $(DOMAIN).pot"; \
	  cd $(srcdir) && $(MSGMERGE_UPDATE) $${lang}.po $(DOMAIN).pot; \
	else \
	  $(MAKE) $${lang}.po-create; \
	fi


install: install-exec install-data
install-exec:
install-data: install-data-yes
	if test "$(PACKAGE)" = "gettext-tools"; then \
	  $(mkdir_p) $(DESTDIR)$(gettextsrcdir); \
	  for file in $(DISTFILES.common) Makevars.template; do \
	    $(INSTALL_DATA) $(srcdir)/$$file \
			    $(DESTDIR)$(gettextsrcdir)/$$file; \
	  done; \
	  for file in Makevars; do \
	    rm -f $(DESTDIR)$(gettextsrcdir)/$$file; \
	  done; \
	else \
	  : ; \
	fi
install-data-no: all
install-data-yes: all
	$(mkdir_p) $(DESTDIR)$(datadir)
	@catalogs='$(CATALOGS)'; \
	for cat in $$catalogs; do \
	  cat=`basename $$cat`; \
	  lang=`echo $$cat | sed -e 's/\.gmo$$//'`; \
	  dir=$(localedir)/$$lang/LC_MESSAGES; \
	  $(mkdir_p) $(DESTDIR)$$dir; \
	  if test -r $$cat; then realcat=$$cat; else realcat=$(srcdir)/$$cat; fi; \
	  $(INSTALL_DATA) $$realcat $(DESTDIR)$$dir/$(DOMAIN).mo; \
	  echo "installing $$realcat as $(DESTDIR)$$dir/$(DOMAIN).mo"; \
	  for lc in '' $(EXTRA_LOCALE_CATEGORIES); do \
	    if test -n "$$lc"; then \
	      if (cd $(DESTDIR)$(localedir)/$$lang && LC_ALL=C ls -l -d $$lc 2>/dev/null) | grep ' -> ' >/dev/null; then \
	        link=`cd $(DESTDIR)$(localedir)/$$lang && LC_ALL=C ls -l -d $$lc | sed -e 's/^.* -> //'`; \
	        mv $(DESTDIR)$(localedir)/$$lang/$$lc $(DESTDIR)$(localedir)/$$lang/$$lc.old; \
	        mkdir $(DESTDIR)$(localedir)/$$lang/$$lc; \
	        (cd $(DESTDIR)$(localedir)/$$lang/$$lc.old && \
	         for file in *; do \
	           if test -f $$file; then \
	             ln -s ../$$link/$$file $(DESTDIR)$(localedir)/$$lang/$$lc/$$file; \
	           fi; \
	         done); \
	        rm -f $(DESTDIR)$(localedir)/$$lang/$$lc.old; \
	      else \
	        if test -d $(DESTDIR)$(localedir)/$$lang/$$lc; then \
	          :; \
	        else \
	          rm -f $(DESTDIR)$(localedir)/$$lang/$$lc; \
	          mkdir $(DESTDIR)$(localedir)/$$lang/$$lc; \
	        fi; \
	      fi; \
	      rm -f $(DESTDIR)$(localedir)/$$lang/$$lc/$(DOMAIN).mo; \
	      ln -s ../LC_MESSAGES/$(DOMAIN).mo $(DESTDIR)$(localedir)/$$lang/$$lc/$(DOMAIN).mo 2>/dev/null || \
	      ln $(DESTDIR)$(localedir)/$$lang/LC_MESSAGES/$(DOMAIN).mo $(DESTDIR)$(localedir)/$$lang/$$lc/$(DOMAIN).mo 2>/dev/null || \
	      cp -p $(DESTDIR)$(localedir)/$$lang/LC_MESSAGES/$(DOMAIN).mo $(DESTDIR)$(localedir)/$$lang/$$lc/$(DOMAIN).mo; \
	      echo "installing $$realcat link as $(DESTDIR)$(localedir)/$$lang/$$lc/$(DOMAIN).mo"; \
	    fi; \
	  done; \
	done

install-strip: install

installdirs: installdirs-exec installdirs-data
installdirs-exec:
installdirs-data: installdirs-data-yes
	if test "$(PACKAGE)" = "gettext-tools"; then \
	  $(mkdir_p) $(DESTDIR)$(gettextsrcdir); \
	else \
	  : ; \
	fi
installdirs-data-no:
installdirs-data-yes:
	$(mkdir_p) $(DESTDIR)$(datadir)
	@catalogs='$(CATALOGS)'; \
	for cat in $$catalogs; do \
	  cat=`basename $$cat`; \
	  lang=`echo $$cat | sed -e 's/\.gmo$$//'`; \
	  dir=$(localedir)/$$lang/LC_MESSAGES; \
	  $(mkdir_p) $(DESTDIR)$$dir; \
	  for lc in '' $(EXTRA_LOCALE_CATEGORIES); do \
	    if test -n "$$lc"; then \
	      if (cd $(DESTDIR)$(localedir)/$$lang && LC_ALL=C ls -l -d $$lc 2>/dev/null) | grep ' -> ' >/dev/null; then \
	        link=`cd $(DESTDIR)$(localedir)/$$lang && LC_ALL=C ls -l -d $$lc | sed -e 's/^.* -> //'`; \
	        mv $(DESTDIR)$(localedir)/$$lang/$$lc $(DESTDIR)$(localedir)/$$lang/$$lc.old; \
	        mkdir $(DESTDIR)$(localedir)/$$lang/$$lc; \
	        (cd $(DESTDIR)$(localedir)/$$lang/$$lc.old && \
	         for file in *; do \
	           if test -f $$file; then \
	             ln -s ../$$link/$$file $(DESTDIR)$(localedir)/$$lang/$$lc/$$file; \
	           fi; \
	         done); \
	        rm -f $(DESTDIR)$(localedir)/$$lang/$$lc.old; \
	      else \
	        if test -d $(DESTDIR)$(localedir)/$$lang/$$lc; then \
	          :; \
	        else \
	          rm -f $(DESTDIR)$(localedir)/$$lang/$$lc; \
	          mkdir $(DESTDIR)$(localedir)/$$lang/$$lc; \
	        fi; \
	      fi; \
	    fi; \
	  done; \
	done

# Define this as empty until I found a useful application.
installcheck:

uninstall: uninstall-exec uninstall-data
uninstall-exec:
uninstall-data: uninstall-data-yes
	if test "$(PACKAGE)" = "gettext-tools"; then \
	  for file in $(DISTFILES.common) Makevars.template; do \
	    rm -f $(DESTDIR)$(gettextsrcdir)/$$file; \
	  done; \
	else \
	  : ; \
	fi
uninstall-data-no:
uninstall-data-yes:
	catalogs='$(CATALOGS)'; \
	for cat in $$catalogs; do \
	  cat=`basename $$cat`; \
	  lang=`echo $$cat | sed -e 's/\.gmo$$//'`; \
	  for lc in LC_MESSAGES $(EXTRA_LOCALE_CATEGORIES); do \
	    rm -f $(DESTDIR)$(localedir)/$$lang/$$lc/$(DOMAIN).mo; \
	  done; \
	done

check: all

info dvi ps pdf html tags TAGS ctags CTAGS ID:

mostlyclean:
	rm -f remove-potcdate.sed
	rm -f stamp-poT
	rm -f core core.* $(DOMAIN).po $(DOMAIN).1po $(DOMAIN).2po *.new.po
	rm -fr *.o

clean: mostlyclean

distclean: clean
	rm -f Makefile Makefile.in POTFILES *.mo

maintainer-clean: distclean
	@echo "This command is intended for maintainers to use;"
	@echo "it deletes files that may require special tools to rebuild."
	rm -f stamp-po $(GMOFILES)

distdir = $(top_builddir)/$(PACKAGE)-$(VERSION)/$(subdir)
dist distdir:
	$(MAKE) update-po
	@$(MAKE) dist2
# This is a separate target because 'update-po' must be executed before.
dist2: stamp-po $(DISTFILES)
	dists="$(DISTFILES)"; \
	if test "$(PACKAGE)" = "gettext-tools"; then \
	  dists="$$dists Makevars.template"; \
	fi; \
	if test -f $(srcdir)/$(DOMAIN).pot; then \
	  dists="$$dists $(DOMAIN).pot stamp-po"; \
	fi; \
	if test -f $(srcdir)/ChangeLog; then \
	  dists="$$dists ChangeLog"; \
	fi; \
	for i in 0 1 2 3 4 5 6 7 8 9; do \
	  if test -f $(srcdir)/ChangeLog.$$i; then \
	    dists="$$dists ChangeLog.$$i"; \
	  fi; \
	done; \
	if test -f $(srcdir)/LINGUAS; then dists="$$dists LINGUAS"; fi; \
	for file in $$dists; do \
	  if test -f $$file; then \
	    cp -p $$file $(distdir) || exit 1; \
	  else \
	    cp -p $(srcdir)/$$file $(distdir) || exit 1; \
	  fi; \
	done

update-po: Makefile
	$(MAKE) $(DOMAIN).pot-update
	test -z "$(UPDATEPOFILES)" || $(MAKE) $(UPDATEPOFILES)
	$(MAKE) update-gmo

# General rule for creating PO files.

.nop.po-create:
	@lang=`echo $@ | sed -e 's/\.po-create$$//'`; \
	echo "File $$lang.po does not exist. If you are a translator, you can create it through 'msginit'." 1>&2; \
	exit 1

# General rule for updating PO files.

.nop.po-update:
	@lang=`echo $@ | sed -e 's/\.po-update$$//'`; \
	if test "$(PACKAGE)" = "gettext-tools"; then PATH=`pwd`/../src:$$PATH; fi; \
	tmpdir=`pwd`; \
	echo "$$lang:"; \
	test "$(srcdir)" = . && cdcmd="" || cdcmd="cd $(srcdir) && "; \
	echo "$${cdcmd}$(MSGMERGE) $$lang.po $(DOMAIN).pot -o $$lang.new.po"; \
	cd $(srcdir); \
	if $(MSGMERGE) $$lang.po $(DOMAIN).pot -o $$tmpdir/$$lang.new.po; then \
	  if cmp $$lang.po $$tmpdir/$$lang.new.po >/dev/null 2>&1; then \
	    rm -f $$tmpdir/$$lang.new.po; \
	  else \
	    if mv -f $$tmpdir/$$lang.new.po $$lang.po; then \
	      :; \
	    else \
	      echo "msgmerge for $$lang.po failed: cannot move $$tmpdir/$$lang.new.po to $$lang.po" 1>&2; \
	      exit 1; \
	    fi; \
	  fi; \
	else \
	  echo "msgmerge for $$lang.po failed!" 1>&2; \
	  rm -f $$tmpdir/$$lang.new.po; \
	fi

$(DUMMYPOFILES):

update-gmo: Makefile $(GMOFILES)
	@:

Makefile: Makefile.in.in Makevars $(top_builddir)/config.status POTFILES.in LINGUAS
	cd $(top_builddir) \
	  && $(SHELL) ./config.status $(subdir)/$@.in po-directories

force:

# Tell versions [3.59,3.63) of GNU make not to export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:
# Special Makefile rules for English message catalogs with quotation marks.

DISTFILES.common.extra1 = quot.sed boldquot.sed en@quot.header en@boldquot.header insert-header.sin Rules-quot

.SUFFIXES: .insert-header .po-update-en

en@quot.po-create:
	$(MAKE) en@quot.po-update
en@boldquot.po-create:
	$(MAKE) en@boldquot.po-update

en@quot.po-update: en@quot.po-update-en
en@boldquot.po-update: en@boldquot.po-update-en

.insert-header.po-update-en:
	@lang=`echo $@ | sed -e 's/\.po-update-en$$//'`; \
	if test "$(PACKAGE)" = "gettext"; then PATH=`pwd`/../src:$$PATH; GETTEXTLIBDIR=`cd $(top_srcdir)/src && pwd`; export GETTEXTLIBDIR; fi; \
	tmpdir=`pwd`; \
	echo "$$lang:"; \
	ll=`echo $$lang | sed -e 's/@.*//'`; \
	LC_ALL=C; export LC_ALL; \
	cd $(srcdir); \
	if $(MSGINIT) -i $(DOMAIN).pot --no-translator -l $$ll -o - 2>/dev/null | sed -f $$tmpdir/$$lang.insert-header | $(MSGCONV) -t UTF-8 | $(MSGFILTER) sed -f `echo $$lang | sed -e 's/.*@//'`.sed 2>/dev/null > $$tmpdir/$$lang.new.po; then \
	  if cmp $$lang.po $$tmpdir/$$lang.new.po >/dev/null 2>&1; then \
	    rm -f $$tmpdir/$$lang.new.po; \
	  else \
	    if mv -f $$tmpdir/$$lang.new.po $$lang.po; then \
	      :; \
	    else \
	      echo "creation of $$lang.po failed: cannot move $$tmpdir/$$lang.new.po to $$lang.po" 1>&2; \
	      exit 1; \
	    fi; \
	  fi; \
	else \
	  echo "creation of $$lang.po failed!" 1>&2; \
	  rm -f $$tmpdir/$$lang.new.po; \
	fi

en@quot.insert-header: insert-header.sin
	sed -e '/^#/d' -e 's/HEADER/en@quot.header/g' $(srcdir)/insert-header.sin > en@quot.insert-header

en@boldquot.insert-header: insert-header.sin
	sed -e '/^#/d' -e 's/HEADER/en@boldquot.header/g' $(srcdir)/insert-header.sin > en@boldquot.insert-header

mostlyclean: mostlyclean-quot
mostlyclean-quot:
	rm -f *.insert-header

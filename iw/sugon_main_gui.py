#
# sugon_main.py: main windows
#
# Copyright (C) 2015  Sugon, Inc.
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author(s): heiden deng <dengjq@sugon.com>
#
import string
import time
import isys
import iutil
import sys
import shutil
import gtk
import gtk.glade
import gobject

import os
import glob

import pango

import gui
from flags import flags
from iw_gui import *
from constants import *
import language

import gettext
_ = lambda x: gettext.ldgettext("anaconda", x)

import logging
log = logging.getLogger("anaconda")

logos_extension = [".jpg", ".bmp", ".png", ".jpeg"]

def getPixbuf_ex(file):
    if not os.access(file, os.R_OK):
        log.error("unable to load %s" %(file,))
        return None

    try:
        pixbuf = gtk.gdk.pixbuf_new_from_file(file)
    except RuntimeError, msg:
        log.error("unable to read %s: %s" %(file, msg))
        pixbuf = None

    return pixbuf

def getIconSet(file):
    pixbuf = getPixbuf_ex(file)
    if pixbuf is None:
        log.error("can't find pixmap %s" %(file,))
        return None

    source = gtk.IconSource()
    source.set_pixbuf(pixbuf)
    source.set_size(gtk.ICON_SIZE_DIALOG)
    source.set_size_wildcarded(False)
    iconset = gtk.IconSet()
    iconset.add_source(source)
    return iconset

#timer callback
def pic_timeout(win):
    if win.get_fraction() > 0.95:
        return False
    win.display_pic()
    return True

def filter_logos(pic_name):
    if pic_name is None or len(pic_name) == 0:
        return False
    for ext in logos_extension:
        if pic_name.endswith(ext):
            return True
    return False


class MainInstallWindow (InstallWindow):
    windowTitle = N_("Installing vCell")

    def __init__ (self, ics):
        InstallWindow.__init__ (self, ics)
        ics.setPrevEnabled (False)
        ics.setNextEnabled (False)
        self.pic_path = "/usr/share/anaconda/pixmaps/logos"
        self.pic_index = -1
        self.pic_mode = 0 # 0: fix ,1:logos but static,2:logos and dynamic
        self.load_pic()
        self._updateChange = 0.001
        self._showPercentage = True

    def load_pic(self):
        pic_files = os.listdir(self.pic_path)
        pic_files = filter(filter_logos, pic_files)
        pic_files.sort()
        pic_full_path = [ os.path.join(self.pic_path,file) for file in pic_files]
        self.pic_buf = []
        try:
            self.pic_buf = [getIconSet(pic) for pic in pic_full_path]
        except:
            log.error("load pic error")
        self.pic_buf = filter(lambda x: x is not None, self.pic_buf)

        if len(self.pic_buf) == 0:
            self.pic_mode = 0
        elif len(self.pic_buf) == 1:
            self.pic_mode = 1
        else:
            self.pic_mode = 2

    def display_pic(self):
        if self.pic_mode == 0:
            self.pic = gui.readImageFromFile ("progress_first.png", False , self.pic)
        else:
            self.pic_index = self.pic_index + 1
            if self.pic_index >= len(self.pic_buf):
                self.pic_index = 0
            self.pic.set_from_icon_set(self.pic_buf[self.pic_index], gtk.ICON_SIZE_DIALOG)


    def getNext (self):
        return None

    def processEvents(self):
        gui.processEvents()

    def get_fraction(self):
        return self.progress.get_fraction()
    def set_fraction(self, pct):
        cur = self.get_fraction()
        if pct - cur > self._updateChange:
            self.progress.set_fraction(pct)
            if self._showPercentage:
                percent = "%d %%" % (pct * 100,)
                progress_text = _("System Installing,Finished:%s") % (percent,)
                self.progress.set_text(progress_text)
            self.processEvents()

    def set_fraction_for_step(self, step, index, end, setLabel = True):
        if self.anaconda.dispatch.stepIsValid(step):
            fraction = self.anaconda.dispatch.get_Fraction(step, index, end)
            if setLabel:
                stepItem = self.anaconda.dispatch.get_StepItem(step)
                stepName = _(stepItem[0]+" tips")
                setpName = '<span foreground="blue"' + stepName + '</span>'
                if index == 0:
                    stepInfo = _("Start install step: %s") % (stepName,)
                    self.set_label("")
                elif index == end:
                    stepInfo = _("Finish install step: %s") % (stepName,)
                else:
                    stepInfo = _("Executing install step: %s") % (stepName,)
                stepInfo = "<b>" + stepInfo + "</b>"
                self.set_label(stepInfo, True)
            return self.set_fraction(fraction)

    def set_fraction_ex(self, index, end, setLabel = True):
        (step, anconda) = self.anaconda.dispatch.currentStepNum()
        return self.set_fraction_for_step(step, index, end, setLabel)

    def set_label(self, txt, isStepLabel = False):
        # handle txt strings that contain '&' and '&amp;'
        # we convert everything to '&' first, then take them all to '&amp;'
        # so we avoid things like &amp;&amp;
        # we have to use '&amp;' for the set_markup() method
        txt = txt.replace('&amp;', '&')
        txt = txt.replace('&', '&amp;')
        if isStepLabel:
            self.steplabel.set_markup(txt)
            self.steplabel.set_ellipsize(pango.ELLIPSIZE_END)
        else:
            self.infolabel.set_markup(txt)
            self.infolabel.set_ellipsize(pango.ELLIPSIZE_END)
        self.processEvents()

    def set_text(self, txt):
        if self._showPercentage:
            log.debug("Setting progress text with showPercentage set")
            return
        self.progress.set_text(txt)
        self.processEvents()

    def renderCallback(self):
        self.intf.icw.nextClicked()

    def setShowPercentage(self, val):
        if val not in (True, False):
            raise ValueError, "Invalid value passed to setShowPercentage"
        self._showPercentage = val


    def getScreen (self, anaconda):
        self.anaconda = anaconda
        self.intf = anaconda.intf
        if not self.anaconda.isSugon:
             self.setShowPercentage(False)
        if anaconda.dir == DISPATCH_BACK:
            self.intf.icw.prevClicked()
            return

        table = gtk.Table(14, 1, False)

        self.pic = gtk.Image()
        self.display_pic()
        frame = gtk.Frame()
        frame.set_shadow_type(gtk.SHADOW_NONE)
        box = gtk.EventBox()
        box.add(self.pic)
        self.adbox = box
        frame.add(box)
        table.attach(frame, 0, 1, 0, 10, gtk.EXPAND | gtk.FILL, gtk.EXPAND | gtk.FILL)

        self.steplabel = gui.WrappingLabel("")
        self.steplabel.set_alignment(0,0)
        table.attach(self.steplabel, 0, 1, 10, 11,gtk.EXPAND | gtk.FILL, 0)

        self.progress = gtk.ProgressBar()
        table.attach(self.progress, 0, 1, 11, 12, gtk.EXPAND | gtk.FILL, 0)

        self.infolabel = gui.WrappingLabel("")
        self.infolabel.set_alignment(0,0)
        table.attach(self.infolabel, 0, 1, 12, 14, gtk.EXPAND | gtk.FILL, gtk.EXPAND | gtk.FILL)

        # All done with creating components of UI
        self.intf.setPackageProgressWindow(self)
        anaconda.id.setInstallProgressClass(self)
        table.set_row_spacing(10, 2)

        if self.pic_mode == 2:
            self.timer = gobject.timeout_add (int(flags.logo_interval), pic_timeout, self)

        return table





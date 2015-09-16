#
# dispatch.py: install/upgrade master flow control
#
# Copyright (C) 2001, 2002, 2003, 2004, 2005, 2006  Red Hat, Inc.
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
# Author(s): Erik Troan <ewt@redhat.com>
#

import string
import os
from types import *
from constants import *
from packages import writeKSConfiguration, turnOnFilesystems
from packages import doPostAction
from packages import copyAnacondaLogs
from packages import firstbootConfiguration
from packages import betaNagScreen
from packages import setupTimezone
from packages import setFileCons
from packages import kickstart_init
from packages import installTarPackages_before
from packages import installTarPackages_after

from storage import storageInitialize
from storage import storageComplete

from storage.partitioning import doAutoPartition
from bootloader import writeBootloader, bootloaderSetupChoices
from flags import flags
from upgrade import upgradeMountFilesystems
from upgrade import upgradeSwapSuggestion, upgradeMigrateFind
from upgrade import findRootParts, queryUpgradeContinue
from installmethod import doMethodComplete
from kickstart import runPostScripts

from backend import doPostSelection, doBackendSetup, doBasePackageSelect
from backend import doPreInstall, doPostInstall, doInstall
from backend import writeConfiguration

from packages import doReIPL

import logging
log = logging.getLogger("anaconda")

# These are all of the install steps, in order. Note that upgrade and
# install steps are the same thing! Upgrades skip install steps, while
# installs skip upgrade steps.

#
# items are one of
#
#	( name )
#	( name, Function )
#
# in the second case, the function is called directly from the dispatcher

# All install steps take the anaconda object as their sole argument.  This
# gets passed in when we call the function.
installSteps = [
    ("kickstartInit", 5, kickstart_init, ),
    ("welcome", 0, ),
    ("language", 0, ),
    ("keyboard", 0, ),
    ("betanag", 0, betaNagScreen, ),
    ("filtertype", 1, ),
    ("filter", 0, ),
    ("storageinit", 1, storageInitialize, ),
    ("findrootparts", 0, findRootParts, ),
    ("findinstall", 0, ),
    ("network", 0, ),
    ("timezone", 0, ),
    ("accounts", 0, ),
    ("setuptime", 1, setupTimezone, ),
    ("parttype", 0, ),
    ("cleardiskssel", 0, ),
    ("autopartitionexecute", 2, doAutoPartition, ),
    ("partition", 0, ),
    ("upgrademount", 0, upgradeMountFilesystems, ),
    ("upgradecontinue", 0, queryUpgradeContinue, ),
    ("upgradeswapsuggestion", 0, upgradeSwapSuggestion, ),
    ("addswap", 0, ),
    ("upgrademigfind", 0, upgradeMigrateFind, ),
    ("upgrademigratefs", 0, ),
    ("storagedone", 1, storageComplete, ),
    ("enablefilesystems", 3, turnOnFilesystems, ),
    ("upgbootloader", 0, ),
    ("bootloadersetup", 1, bootloaderSetupChoices, ),
    ("bootloader",0, ),
    ("reposetup", 3, doBackendSetup, ),
    ("installTarBefore", 0, installTarPackages_before, ),
    ("tasksel", 0,),
    ("basepkgsel", 1, doBasePackageSelect, ),
    ("group-selection",0, ),
    ("postselection", 1, doPostSelection, ),
    ("install",0, ),
    ("preinstallconfig", 1, doPreInstall, ),
    ("installpackages", 65, doInstall, ),
    ("postinstallconfig", 1, doPostInstall, ),
    ("installTarAfter", 0, installTarPackages_after, ),
    ("writeconfig", 1, writeConfiguration, ),
    ("firstboot", 1,firstbootConfiguration, ),
    ("instbootloader",2, writeBootloader, ),
    ("reipl", 0, doReIPL, ),
    ("writeksconfig", 1, writeKSConfiguration, ),
    ("setfilecon", 1, setFileCons, ),
    ("copylogs", 1, copyAnacondaLogs, ),
    ("methodcomplete", 1, doMethodComplete, ),
    ("postscripts", 3, runPostScripts, ),
    ("dopostaction", 2,doPostAction, ),
    ("complete",0, ),
    ]

class Dispatcher(object):
    def get_StepsLen(self):
        installSteps_len = len(installSteps)
        return installSteps_len

    def get_WeightLst(self):
        weight_lst = [item[1] for item in installSteps]
        return weight_lst

    def get_StepWeightsBefore(self, step):
        if step <= 0:
            return 0
        elif step > self.get_StepsLen() - 1:
            return 100
        else:
            weights = sum(self.get_WeightLst()[:step])
            if weights > 100:
                weights = 100
            return weights

    def get_Fraction(self, step, index, end):
        if step < 0 or end <= 0:
            return 0
        elif (step > self.get_StepsLen()-1):
            return 1
        pct = (index * (1.0) / end )
        if index >= end:
            pct = 1.0
        weight_list = self.get_WeightLst()
        weight_curr = weight_list[step]
        weight_accum = self.get_StepWeightsBefore(step)
        weight_total = sum(weight_list)
        fraction = (weight_accum + pct * weight_curr)/weight_total
        return fraction

    def stepIsValid(self, step):
        if step < 0 or step >= self.get_StepsLen():
            return False
        return True

    def get_StepItem(self,step):
        if self.stepIsValid(step):
            return installSteps[step]
        return None

    def gotoPrev(self):
        self._setDir(DISPATCH_BACK)
	self.moveStep()

    def gotoNext(self):
	self._setDir(DISPATCH_FORWARD)
	self.moveStep()

    def canGoBack(self):
        # begin with the step before this one.  If all steps are skipped,
        # we can not go backwards from this screen
        if self.step is None:
            return False
        i = self.step - 1
        while i >= self.firstStep:
            if not self.stepIsDirect(i) and not self.skipSteps.has_key(installSteps[i][0]):
                return True
            i = i - 1
        return False

    def setStepList(self, *steps):
        # only remove non-permanently skipped steps from our skip list
        for step, state in self.skipSteps.items():
            if state == 1:
                del self.skipSteps[step]

	stepExists = {}
	for step in installSteps:
	    name = step[0]
	    if not name in steps:
		self.skipSteps[name] = 1

	    stepExists[name] = 1

	for name in steps:
	    if not stepExists.has_key(name):
                #XXX: hack for yum support
		#raise KeyError, ("step %s does not exist" % name)
                log.warning("setStepList: step %s does not exist", name)

    def stepInSkipList(self, step):
        if type(step) == type(1):
            step = installSteps[step][0]
	return self.skipSteps.has_key(step)

    def insertSteps(self, index, item):
        installSteps.insert(index, item)

    def removeSteps(self, index):
        del installSteps[index]

    def skipStep(self, stepToSkip, skip = 1, permanent = 0):
        if skip == 1:
            skip_method = "add"
        else:
            skip_method = "remove"
        log.warning("skipStep:skip %s(%s)",stepToSkip,skip_method)
        for step in installSteps:
	    name = step[0]
	    if name == stepToSkip:
		if skip:
                    if permanent:
                        self.skipSteps[name] = 2
                    elif not self.skipSteps.has_key(name):
                        self.skipSteps[name] = 1
		elif self.skipSteps.has_key(name):
		    # if marked as permanent then dont change
		    if self.skipSteps[name] != 2:
			del self.skipSteps[name]
		return

	#raise KeyError, ("unknown step %s" % stepToSkip)
        log.warning("skipStep: step %s does not exist", stepToSkip)

    def stepIsDirect(self, step):
        """Takes a step number"""
        if len(installSteps[step]) == 3:
            return True
        else:
            return False

    def moveStep(self):
	if self.step == None:
	    self.step = self.firstStep
	else:
            if self.step >= len(installSteps):
                return None

            log.info("leaving (%d) step %s" %(self._getDir(), installSteps[self.step][0]))
            self.step = self.step + self._getDir()

            if self.step >= len(installSteps):
                return None

        while self.step >= self.firstStep and self.step < len(installSteps) \
            and (self.stepInSkipList(self.step) or self.stepIsDirect(self.step)):

            if self.anaconda.isSugon and hasattr(self.anaconda.id, "instProgress") and self.anaconda.id.instProgress:
                self.anaconda.id.instProgress.set_fraction_for_step(self.step, 0, 1)

            if self.stepIsDirect(self.step) and not self.stepInSkipList(self.step):
	        (stepName, weight, stepFunc) = installSteps[self.step]
                log.info("moving (%d) to step %s" %(self._getDir(), stepName))
                log.debug("%s is a direct step" %(stepName,))
                rc = stepFunc(self.anaconda)
                if rc in [DISPATCH_BACK, DISPATCH_FORWARD]:
		    self._setDir(rc)
                log.info("leaving (%d) step %s" %(self._getDir(), stepName))
		# if anything else, leave self.dir alone

            if self.anaconda.isSugon and hasattr(self.anaconda.id, "instProgress") and self.anaconda.id.instProgress:
                if self._getDir() == DISPATCH_FORWARD:
                    self.anaconda.id.instProgress.set_fraction_for_step(self.step, 1, 1)

	    self.step = self.step + self._getDir()
	    if self.step == len(installSteps):
		return None

	if (self.step < 0):
	    # pick the first step not in the skip list
	    self.step = 0
	    while self.skipSteps.has_key(installSteps[self.step][0]):
		self.step = self.step + 1
	elif self.step >= len(installSteps):
	    self.step = len(installSteps) - 1
	    while self.skipSteps.has_key(installSteps[self.step][0]):
		self.step = self.step - 1
        log.info("moving (%d) to step %s" %(self._getDir(), installSteps[self.step][0]))

    def currentStepNum(self):
	if self.step == None:
	    self.gotoNext()
	elif self.step >= len(installSteps):
	    return (None, None)
	return (self.step, self.anaconda)


    def currentStep(self):
	if self.step == None:
	    self.gotoNext()
	elif self.step >= len(installSteps):
	    return (None, None)

	stepInfo = installSteps[self.step]
	step = stepInfo[0]

	return (step, self.anaconda)

    def createStepWeightDict(self):
        self.step_file = "/tmp/step_weight.info"
        self.step_dict = {}
        if os.access(self.step_file, os.R_OK):
            f = open(self.step_file, 'r')
            contents = [line.strip('\n') for line in f.readlines()]
            for item in contents:
                try:
                    (key, value) = item.split('=', 1)
                except:
                    key = item
                    value = 0
                if key:
                    key = key.strip()
                if value:
                    value = value.strip()
                self.step_dict[key] = int(value)
            f.close()
        return self.step_dict

    def setupStepWeight(self):
        global installSteps
        installSteps_Final = []
        stepWeight_dict = self.createStepWeightDict()
        if len(stepWeight_dict) == 0:
            return
        for item in installSteps:
            if not stepWeight_dict.has_key(item[0]):
                installSteps_Final.append(item)
	    else:
                step_item = None
                if len(item) == 2:
                    step_item = (item[0], stepWeight_dict[item[0]])
                else:
                    step_item = (item[0], stepWeight_dict[item[0]], item[2])
                installSteps_Final.append(step_item)
        installSteps = []
        installSteps.extend(installSteps_Final)

    def __init__(self, anaconda):
        self.anaconda = anaconda
        self.anaconda.dir = DISPATCH_FORWARD
        self.step = None
        self.skipSteps = {}
        self.firstStep = 0
        self.setupStepWeight()

    def _getDir(self):
        return self.anaconda.dir

    def _setDir(self, dir):
        self.anaconda.dir = dir

    dir = property(_getDir,_setDir)

#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" ${1+"$@"}

lappend auto_path "."
package require practice

gui::initialize

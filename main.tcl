#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

lappend auto_path "."
package require practice

gui::initialize

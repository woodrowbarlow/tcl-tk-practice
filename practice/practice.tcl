package require Tk
package require Ttk

package provide practice 1.0

namespace eval ::gui {
    namespace export initialize
}

namespace eval ::util { }

# util::getoptions
#
#       Given a list of arguments and an array filled with option
#       names, populate the array with the arguments whose names
#       match and return a list of the remaining arguments.
#
# Arguments
#
#       args        A list of arguments.
#
#       optionsname The name of an array of options, pre-filled with
#                   names and default values.
#
# Return Value
#
#       A list of arguments which did not match those specified.

proc util::getoptions { args optsname } {
    upvar 1 $optsname opts
    set std [list]
    set keys [array names opts]
    foreach {opt val} $args {
        if {[lsearch -exact $keys $opt] >= 0} {
            set opts($opt) $val
        } else {
            lappend std $opt $val
        }
    }
    return $std
}

# gui::mainframe (ttk::frame)
#
#       Construct a main frame for the practice GUI. The parent element
#       is a frame, and it contains a series of children widgets for each
#       element added to the main frame.
#
# Options:
#
#       -test       Text to be placed into the label.
#
# Commands:
#
#       test        Print a debug message to the console.

proc gui::mainframe { w args } {
    # set a default value for all custom options
    array set options {
        -test       ""
        -test2      ""
    }

    # populate the options array with values from `args`
    # additionally, strip the custom options out of `args`
    set args [util::getoptions $args options]

    # create the frame for this widget, which acts as a container
    eval [list ttk::frame $w] $args

    # when we create an element, like the frame above, tk creates
    # a proc with that element's path as the name. in order to
    # implement custom commands, we can shadow that proc.
    rename $w _$w
    proc $w { cmd args } {
        # the variable `w` doesn't exist within this subproc
        # but the proc is named after `w`, and `info level 0`
        # begins with the proc name.
        set w [lindex [info level 0] 0]
        switch -- $cmd {
            test -
            test2 {
                # invoke a custom handler
                mainframe'$cmd $w $args
            }
            default {
                # non-custom commands get passed to the shadowproc.
                # `uplevel 1` allows it to run with the same runlevel as
                # this subproc (and with the same name).
                uplevel 1 _$w $cmd $args
            }
        }
    }

    # now, start putting stuff in the frame
    pack [list [ttk::label $w.lbl -text $options(-test)]]
    pack [list [ttk::button $w.btn -text $options(-test2)]]

    # return the frame's identifier so something else can pass it
    # directly into a layout manager
    return $w
}

# gui::mainframe'test
#
#       Handle the 'test' command on a mainframe element. Simply prints a
#       debug message to the console, along with the provided arguments.
#
# Arguments:
#
#       A list of strings to be printed to the console.

proc gui::mainframe'test { w args } {
    puts "test command on $w"
    puts $args
}

# gui::initialize
#
#       Initialize the GUI (spawn the window and populate it).

proc gui::initialize { } {
    set mainframe [
        gui::mainframe .mainframe \
                -height 500 -width 400 \
                -test "hello world" -test2 "click"
    ]
    place $mainframe -x 0 -y 0
    # invoke a custom command
    $mainframe test with arguments
}

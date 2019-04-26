package require Tk
package require Ttk

package provide practice 1.0

namespace eval ::gui {
    namespace export initialize
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
    array set custom_args { -test {} }
    set std_args [list]
    foreach {opt val} $args {
        switch -- $opt {
            -test {
                set custom_args($opt) $val
            }
            default {
                # non-custom options will be passed to the frame
                lappend std_args $opt $val
            }
        }
    }

    # create the frame for this widget, which acts as a container
    eval [list ttk::frame $w] $std_args

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
            test {
                # invoke a custom handler
                mainframe'test $w $args
            }
            default {
                # non-custom commands get passed to the shadowproc
                uplevel 1 _$w $cmd $args
            }
        }
    }

    # now, start putting stuff in the frame
    pack [list [ttk::label $w.lbl -text $custom_args(-test)]]
    pack [list [ttk::button $w.btn -text "click me"]]

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
    puts "custom command on $w"
    puts $args
}

# gui::initialize
#
#       Initialize the GUI (spawn the window and populate it).

proc gui::initialize { } {
    set mainframe [gui::mainframe .mainframe \
            -test "hello world" -height 500 -width 400]
    place $mainframe -x 0 -y 0
    # invoke a custom command
    $mainframe test with arguments
}

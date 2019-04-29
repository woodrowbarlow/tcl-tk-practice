package require Tk
package require Ttk

package provide practice 1.0

namespace eval ::gui {
    namespace export initialize
}

proc gui::mainframe { w args } {
    # set a default value for all custom options
    set defaultoptions [dict create -test "" -test2 ""]
    set options [dict merge $defaultoptions $args]
    set args [dict remove $options -test -test2]
    set options [dict filter $options key {*}[dict keys $defaultoptions]]

    # create the frame for this widget, which acts as a container
    ttk::frame $w {*}$args

    # when we create an element, like the frame above, tk creates
    # a command with that element's path as the name. in order to
    # implement custom commands, we can shadow that proc.
    rename $w ::[set w]::_
    namespace eval ::$w {
        variable w [namespace current]
        proc _unknown { ns cmd args } {
            variable w
            return [list ::[set w]::_ $cmd $args]
        }
        proc test { args } {
            variable w
            gui::mainframe'test $w $args
        }
        namespace export *
        namespace ensemble create -prefixes 0 -unknown ::[namespace current]::_unknown
    }

    # now, start putting stuff in the frame
    pack [ttk::label $w.lbl -text [dict get $options -test]]
    pack [ttk::button $w.btn -text [dict get $options -test2]]

    # return the frame's identifier so something else can pass it
    # directly into a layout manager
    return $w
}

proc gui::mainframe'test { w args } {
    puts "test command $w $args"
}

# gui::initialize
#
#       Initialize the GUI (spawn the window and populate it).

proc gui::initialize { } {
    gui::mainframe .mainframe -height 500 -width 400 \
            -test "hello world" -test2 "click"
    place .mainframe -x 0 -y 0
    # invoke a custom command
    .mainframe test with arguments
}

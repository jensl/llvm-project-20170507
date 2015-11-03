"""Test that anonymous structs/unions are transparent to member access"""

from __future__ import print_function

import use_lldb_suite

import os, time
import lldb
from lldbsuite.test.lldbtest import *
import lldbsuite.test.lldbutil as lldbutil

class AnonymousTestCase(TestBase):

    mydir = TestBase.compute_mydir(__file__)

    @skipIfIcc # llvm.org/pr15036: LLDB generates an incorrect AST layout for an anonymous struct when DWARF is generated by ICC
    def test_expr_nest(self):
        self.build()
        self.common_setup(self.line0)

        # These should display correctly.
        self.expect("expression n->foo.d", VARIABLES_DISPLAYED_CORRECTLY,
            substrs = ["= 4"])
            
        self.expect("expression n->b", VARIABLES_DISPLAYED_CORRECTLY,
            substrs = ["= 2"])

    def test_expr_child(self):
        self.build()
        self.common_setup(self.line1)

        # These should display correctly.
        self.expect("expression c->foo.d", VARIABLES_DISPLAYED_CORRECTLY,
            substrs = ["= 4"])
            
        self.expect("expression c->grandchild.b", VARIABLES_DISPLAYED_CORRECTLY,
            substrs = ["= 2"])

    @skipIfIcc # llvm.org/pr15036: This particular regression was introduced by r181498
    def test_expr_grandchild(self):
        self.build()
        self.common_setup(self.line2)

        # These should display correctly.
        self.expect("expression g.child.foo.d", VARIABLES_DISPLAYED_CORRECTLY,
            substrs = ["= 4"])
            
        self.expect("expression g.child.b", VARIABLES_DISPLAYED_CORRECTLY,
            substrs = ["= 2"])

    def test_expr_parent(self):
        self.build()
        if "clang" in self.getCompiler() and "3.4" in self.getCompilerVersion():
            self.skipTest("llvm.org/pr16214 -- clang emits partial DWARF for structures referenced via typedef")
        self.common_setup(self.line2)

        # These should display correctly.
        self.expect("expression pz", VARIABLES_DISPLAYED_CORRECTLY,
            substrs = ["(type_z *) $", " = 0x0000"])

        self.expect("expression z.y", VARIABLES_DISPLAYED_CORRECTLY,
            substrs = ["(type_y) $", "dummy = 2"])

    @expectedFailureWindows('llvm.org/pr21550')
    def test_expr_null(self):
        self.build()
        self.common_setup(self.line2)

        # This should fail because pz is 0, but it succeeds on OS/X.
        # This fails on Linux with an upstream error "Couldn't dematerialize struct", as does "p *n" with "int *n = 0".
        # Note that this can also trigger llvm.org/pr15036 when run interactively at the lldb command prompt.
        self.expect("expression *(type_z *)pz", error = True)

    def test_child_by_name(self):
        self.build()
        
        # Set debugger into synchronous mode
        self.dbg.SetAsync(False)

        # Create a target
        exe = os.path.join (os.getcwd(), "a.out")
        target = self.dbg.CreateTarget(exe)
        self.assertTrue(target, VALID_TARGET)

        break_in_main = target.BreakpointCreateBySourceRegex ('// Set breakpoint 2 here.', lldb.SBFileSpec(self.source))
        self.assertTrue(break_in_main, VALID_BREAKPOINT)

        process = target.LaunchSimple (None, None, self.get_process_working_directory())
        self.assertTrue (process, PROCESS_IS_VALID)

        threads = lldbutil.get_threads_stopped_at_breakpoint (process, break_in_main)
        if len(threads) != 1:
            self.fail ("Failed to stop at breakpoint in main.")

        thread = threads[0]
        frame = thread.frames[0]

        if not frame.IsValid():
            self.fail ("Failed to get frame 0.")

        var_n = frame.FindVariable("n")
        if not var_n.IsValid():
            self.fail ("Failed to get the variable 'n'")

        elem_a = var_n.GetChildMemberWithName("a")
        if not elem_a.IsValid():
            self.fail ("Failed to get the element a in n")

        error = lldb.SBError()
        value = elem_a.GetValueAsSigned(error, 1000)
        if not error.Success() or value != 0:
            self.fail ("failed to get the correct value for element a in n")

    def setUp(self):
        # Call super's setUp().
        TestBase.setUp(self)
        # Find the line numbers to break in main.c.
        self.source = 'main.c'
        self.line0 = line_number(self.source, '// Set breakpoint 0 here.')
        self.line1 = line_number(self.source, '// Set breakpoint 1 here.')
        self.line2 = line_number(self.source, '// Set breakpoint 2 here.')

    def common_setup(self, line):
        
        # Set debugger into synchronous mode
        self.dbg.SetAsync(False)

        # Create a target
        exe = os.path.join(os.getcwd(), "a.out")
        target = self.dbg.CreateTarget(exe)
        self.assertTrue(target, VALID_TARGET)

        # Set breakpoints inside and outside methods that take pointers to the containing struct.
        lldbutil.run_break_set_by_file_and_line (self, self.source, line, num_expected_locations=1, loc_exact=True)

        # Now launch the process, and do not stop at entry point.
        process = target.LaunchSimple (None, None, self.get_process_working_directory())
        self.assertTrue(process, PROCESS_IS_VALID)

        # The stop reason of the thread should be breakpoint.
        self.expect("thread list", STOPPED_DUE_TO_BREAKPOINT,
            substrs = ['stopped',
                       'stop reason = breakpoint'])

        # The breakpoint should have a hit count of 1.
        self.expect("breakpoint list -f", BREAKPOINT_HIT_ONCE,
            substrs = [' resolved, hit count = 1'])

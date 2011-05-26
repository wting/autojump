from __future__ import division, print_function
import cProfile, sys, imp, os, pstats
autojump = imp.load_source('autojump', 'autojump')

"""Profile the total time taken for autojump to generate completions as a
function of pattern length. This file must be run from the project root."""

if os.path.exists('./profile/autojump_py'):
    autojump.CONFIG_DIR = './profile'

if len(sys.argv) > 1:
    outfile = open(sys.argv[1], 'w')
else:
    outfile = open('profile_results', 'w')
outfile.write('Pattern length\tTime taken/s\n')

# For maximum running time, we don't want to match any files.
test_search = '#' * 10
for i in range(0, 10):
    autojump.argv = ['', '--completion', test_search[:i+1]]
    cProfile.run('autojump.shell_utility()', 'shellprof')
    p = pstats.Stats('shellprof')
    outfile.write("%s\t%s\n"% (i + 1, p.total_tt))
p.sort_stats('time')
p.print_stats(10)


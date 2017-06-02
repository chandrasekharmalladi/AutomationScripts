import sys, os
cmd = 'find . -name "test.txt" -exec chmod 777 {} \;'

os.system(cmd)

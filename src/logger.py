import errno
import os
import sys

class Logger(object):
    def __init__(self, logfile):
        self.terminal = sys.stdout
        self.log = open(logfile, "a")

    def write(self, message):
        self.terminal.write(message)
        self.log.write(message)  

    def flush(self):
        pass

def delete_logs(logfiles):
    for lf in logfiles:
        try:
            os.remove(lf)
        except OSError as e:
            if e.errno != errno.ENOENT:
                raise EnvironmentError("Could not delete the log file (= %s)." % str(lf))

import csv
import errno
import os
import sys

def count_distinct(dic):
    count = 0
    for v in dic.values():
        if v == 1:
            count += 1
    return count

def filter_nodes(dic):    
    filtered = {k: v for k, v in dic.items() if v > 1}
    return filtered

def write_csv(output_dir, output_file, fields, data):
    print "\n===================================================================="
    print "Writing the results to a CSV file (%s)..." % output_file
    output_path = os.path.join(os.path.abspath(".."), output_dir)
    create_output_dir(output_path)

    with open(os.path.join(output_path, output_file), "w") as csvfile:
        writer = csv.writer(csvfile, dialect = csv.excel)
        writer.writerow(fields)
        writer.writerows(data)
    print "Writing complete!"
    print "===================================================================="

def create_output_dir(output_dir):
    try:
        os.makedirs(output_dir)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise EnvironmentError("Could not create the output directory (= %s)." % str(os.path.basename(os.path.normpath(output_dir))))

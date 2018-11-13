#!/usr/bin/env python3
# ----------------------------------------------
# Base python script with argument parsing and
# help and some utility functions
# ----------------------------------------------

import argparse
import logging
import sys
import subprocess
import os
import platform
from threading import Thread

log_file = '/dev/null'

# Argument parser setup with subcommand support
def parse_args():
    parser = argparse.ArgumentParser(description='Example parser')
    subparsers = parser.add_subparsers(help='sub-command help')

    ex_parser = subparsers.add_parser('example-subcommand', aliases=['es'],
        help='Example subcommand')
    ex_parser.set_defaults(func=example)

    parser.add_argument('-l', '--logfile',
                        help='Output into a log file instead of stdout')
    parser.add_argument('-v', '--verbose',
                        dest='verbose_count',
                        action='count',
                        default=0,
                        help='Increases log verbosity for console for each occurence.')

    return parser.parse_args()

# Logger setup
def setup_logger(args):
    if args.logfile:
        logging.info('Logging to log file at {}'.format(args.logfile))
        global log_file
        log_file = args.logfile

    file_handler = logging.FileHandler(log_file, 'w')
    file_handler.setLevel(logging.DEBUG)

    console_handler = logging.StreamHandler()
    if args.verbose_count > 0:
        console_handler.setLevel(logging.DEBUG)
    else:
        console_handler.setLevel(logging.INFO)

    logging.basicConfig(
        level = logging.DEBUG,
        format = '%(message)s',
    )

    root_logger = logging.getLogger('')
    root_logger.handlers = []
    root_logger.addHandler(console_handler)
    root_logger.addHandler(file_handler)

# Pipe consumer
def consume_pipe(pipe, consumer):
    with pipe:
        for line in iter(pipe.readline, b''):
            if len(line) is 0:
                break

            consumer(line.rstrip())

# Run command with subprocess.Popen
def run_command(args, check_code = True, cwd = '.'):
    logging.debug('Running command {}'.format(' '.join(args)))
    process = subprocess.Popen(args, cwd=cwd, stdin=None,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            universal_newlines=True, bufsize=1)

    consumer = lambda line: logging.debug(line)
    t = Thread(target=consume_pipe, args=[process.stdout, consumer]).start()

    code = process.wait()
    if code is not 0 and check_code:
        logging.error('!!! Command {} failed with code {}'.format(' '.join(args), code))
        sys.exit(1)

# Ensure that user is root
def ensure_root():
    if os.geteuid() != 0:
        logging.info('User is not root. Please run with \'sudo ' +
                os.path.basename(__file__) + ' <command>\'')
        sys.exit(1)

# Install package by its name on linux distributions
def install_package(package_name):
    ensure_root()
    dist = platform.dist()[0].lower()
    args = []
    if dist == 'ubuntu' or dist == 'debian':
        args = ['apt-get', 'install', '-y']
    elif dist == 'fedora':
        args = ['dnf', 'install', '-y']
    elif dist == 'arch':
        args = ['pacman', '-S', '--noconfirm']
    elif dist == 'centos':
        args = ['yum', 'install', '-y']
    else:
        logging.error('!!! Your distribution {} is not supported! Exiting now...'.format(dist))
        sys.exit(1)

    args.append(package_name)
    logging.info('Installing package {}'.format(package_name))
    run_command(args)

# Main
def main():
    args = parse_args()

    setup_logger(args)

    if hasattr(args, 'func') and args.func:
        args.func(args)
    else:
        logging.error('Missing sub-command. See help')
        sys.exit(1)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        logging.error('');
        logging.error('Interrupted by user!')

#!/usr/bin/env python3

import argparse
import sys
from passlib.hash import bcrypt


def parse_arguments():
    """Get commandline arguments."""
    parser = argparse.ArgumentParser(
        description='Hash password for wireguard-ui with bcrypt')
    parser.add_argument('--stdin', '-s', action='store_true',
                        help='Read cleartext password from stdin')
    return parser.parse_args()


def main():
    args = parse_arguments()
    if args.stdin:
        password = sys.stdin.read()
    else:
        password = input('Password: ')
    hashed = bcrypt.hash(password.encode(), rounds=14, ident='2a')
    print(hashed.replace('$', '$$'))


if __name__ == '__main__':
    main()

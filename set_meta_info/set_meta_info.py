import json
import os
import shutil

from optparse import OptionParser

def initialize():
    tokens_filename = 'meta_tokens.json'
    file_list_filename = 'meta_files.json'

    cfg = {}
    tokens_filename = os.path.join(os.path.dirname(__file__), tokens_filename)
    file_list_filename = os.path.join(os.path.dirname(__file__), file_list_filename)

    with open(tokens_filename) as tokens_file:
        cfg['tokens'] = json.load(tokens_file)
    tokens_file.close()

    with open(file_list_filename) as file_list_file:
        cfg['file_list'] = json.load(file_list_file)
    file_list_file.close()

    return cfg


def create_backup_file(filename):
    backup_filename = "{0}.orig".format(filename)
    shutil.copyfile(filename, backup_filename)
    return backup_filename


def replace_tokens(cfg):
    for curr_filename in cfg['file_list']:
        replace_tokens_in_file(cfg['tokens'], curr_filename)


def replace_tokens_in_file(tokens, curr_filename):

    sourcefile = open(create_backup_file(curr_filename), 'r')
    destination_file = open(curr_filename, 'w')

    for line in sourcefile:
        for token_key in tokens.keys():
            line = replace_token(token_key, tokens[token_key], line)
        destination_file.write(line)

    destination_file.close()


def replace_token(token, value, from_string):
    return from_string.replace(token, value)


def main():
    cfg = initialize()
    replace_tokens(cfg)

if __name__ == '__main__':
    main()

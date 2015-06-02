import shutil
import os

qa_tokens = {"<": "<QA-"}
dev_tokens = {"<": "<DEV-"}
prod_tokens = {"<": "<PROD-"}

qa_files = []
dev_files = []
prod_files = []

def copy_templates():
    template_dir = os.path.join(os.path.dirname(__file__), 'template')
    source_files = os.listdir(template_dir)
    destination = os.getcwd()

    for filename in source_files:
        if filename.endswith(".txt"):
            source_file = os.path.join(template_dir, filename)

            destination_file = os.path.join(destination, "qa_{0}".format(filename))
            qa_files.append(destination_file)
            shutil.copy(source_file, destination_file)

            destination_file = os.path.join(destination, "dev_{0}".format(filename))
            dev_files.append(destination_file)
            shutil.copy(source_file, destination_file)

            destination_file = os.path.join(destination, "prod_{0}".format(filename))
            prod_files.append(destination_file)
            shutil.copy(source_file, destination_file)


def tailor_tags(file_list, tokens):
    for filename in file_list:
        replace_tokens_in_file(tokens, filename)


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


def create_backup_file(filename):
    backup_filename = "{0}.orig".format(filename)
    shutil.copyfile(filename, backup_filename)
    return backup_filename


def main():
    copy_templates()
    tailor_tags(dev_files, dev_tokens)
    tailor_tags(qa_files, qa_tokens)
    tailor_tags(prod_files, prod_tokens)

if __name__ == "__main__":
    main()

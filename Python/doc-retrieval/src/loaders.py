"""
Module with the needed functions to load the corpus of documents.
"""
import re

SEPARATOR = r".I "
NEW_LINE = r"\r\n"
DOC_START = NEW_LINE + r".W" + NEW_LINE


def load_docs(file):
    """Loads the documents in the MED.ALL file."""
    with open(file, "r") as f:
        content = re.split(SEPARATOR, f.read())
        docs = {}
        for elem in content:
            if elem is "":
                pass
            else:
                split = re.split(DOC_START, elem)
                docs[split[0]] = split[1]

    return docs


def load_ground_truth(file):
    """Load the queries in the MED.QRY file."""
    with open(file, "r") as f:
        content = re.split("\n", f.read())
        rel = {}
        for row in content:
            if row is "":
                pass
            else:
                split = re.split(" ", row)
                if(split[0] not in rel):
                    rel[split[0]] = []
                rel[split[0]].append(split[2])
    return rel

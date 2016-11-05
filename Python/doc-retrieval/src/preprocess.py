"""
Module with the implemention of the Preprocessor class, which
implements the document preprocessing functionality.
"""

from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
from nltk.tokenize import wordpunct_tokenize


class Preprocessor:
    def __init__(self):
        self.stopset = set(stopwords.words('english'))
        self.stemmer = PorterStemmer()

    def preprocess(self, doc):
        tokens = [token.lower() for token in wordpunct_tokenize(doc)]
        clean = [token for token in tokens
                 if token not in self.stopset and len(token) > 2]
        return [self.stemmer.stem(word) for word in clean]

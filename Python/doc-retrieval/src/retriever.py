"""
Module with the implemention of the DocRetriever class, which
represents a system holding a collection of documents that can
be retrieved.
"""

import math
from operator import itemgetter

from gensim import corpora, models, similarities
from preprocess import Preprocessor


# Define some term frequency functions
TF = {"binary": lambda f: int(f > 1),
      "raw": lambda f: f,
      "log2norm": lambda f: 1 + math.log(f, 2)}
# Define some inverse document frequency functions
IDF = {"unary": lambda df, D: 1,
       "inv": lambda df, D: math.log(D/df, 2),
       "smooth": lambda df, D: math.log(1 + D/df, 2)}


class DocRetriever:
    """
    Possible modes for tf weights:
        "binary"    -   Wether the term appears or not
        "raw"       -   Times the term appears
        "log2norm"  -   2 base logarithmic normalization
    Possible modes fro idf weights:
        "unary"     -   Always 1
        "inv"       -   Inverse frequency
        "smooth"    -   Smooth inverse frequency

    """
    def __init__(self, docs, docids=None, tf="raw", idf="inv",
                 tmpfile="/tmp/dr_docs.mm"):
        if docids is None:
            docids = range(len(docs))
        if len(docs) != len(docids):
            raise ValueError("The length of 'docs' and 'docids' must be" +
                             "the same.")
        # Create a preprocessor
        self.preprocessor = Preprocessor()
        # Save doc ids
        self.docids = docids
        # Preprocess documents
        prep_docs = [self.preprocessor.preprocess(doc) for doc in docs]
        # Create ditionary with preprocessed documents
        self.dict = corpora.Dictionary(prep_docs)
        # Create corpus
        corpora.MmCorpus.serialize(tmpfile, [self.dict.doc2bow(doc)
                                             for doc in prep_docs])
        self.mm = corpora.MmCorpus(tmpfile)
        # self.mm document stream now has random access

        # Build model of weights according to mode
        self.model = models.TfidfModel(self.mm, wlocal=TF[tf],
                                       wglobal=IDF[idf])

        # Build index
        self.index = similarities.MatrixSimilarity(self.mm,
                                                   num_features=len(self.dict))

    def save_dictionary(self, file="/tmp/dr.dict"):
        self.dict.save(file)

    def print_dictionary(self):
        print(self.dict.token2id)

    def query(self, q, threshold=-1):
        pq = self.dict.doc2bow(self.preprocessor.preprocess(q))
        ranking = sorted(zip(self.docids, self.index[self.model[pq]]),
                         key=itemgetter(1),
                         reverse=True)
        return [(doc, score) for doc, score in ranking if score >= threshold]

    def _results(self, doc, score):
        return str("[ Score = " +
                   "%.3f" % round(score, 3) +
                   "] " +
                   self.docids[doc])

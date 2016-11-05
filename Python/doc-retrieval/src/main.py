"""Main script"""

from retriever import DocRetriever
import loaders
import os


# Define some constants
# File containing the corpus
FILE = os.path.dirname(os.path.abspath(__file__)) + "/../data/MED.ALL"
DEF_SCORE = 0.001  # Default minimum score to restrieve docs

# Define some interaction messages
ACTION1 = "\t1: Perform a query\n"
ACTION2 = "\t2: Change minimum score to retrieve a document\n"
ACTION3 = "\t3: Exit\n"
ACTIONS = ("Select an action to perform:\n" + ACTION1 + ACTION2 + ACTION3)
QUERY = "Type your query:\n"
CHANGE_SCORE = ("\rType the new value for the minimum score " +
				"(from 0.0 (all docs) to 1.0 (perfect match)):\n"
				)


# Auxiliar functions
def perform_query(dc, score):
	q = str(raw_input(QUERY))
	return dc.query(q, score)


def print_results(res, score):
	print("\nShowing results with a minimum score of " + str(score) + " :")
	for id, score in res:
		print("[Score = " + str(score) + " ][Id = " +
			  str(id) + "]: " + str(docs[id][0:100]) + "...")
	print("")


def change_min_score():
	try:
		return float(raw_input(CHANGE_SCORE))
	except ValueError:
		print("The given value could not be interpreted as a number.")
		raise ValueError


def select_tf():
	tf = 0
	while(tf > 3 or tf < 1):
		print("Choose one of the next TF functions to use:")
		try:
			tf = int(raw_input("\t1: Raw\n\t2: log2norm\n"))
		except:
			tf = 0
		if tf not in [1, 2]:
			print("Selected mode not recognized. Please try again.")
	if tf == 1:
		return "raw"
	elif tf == 2:
		return "log2norm"

def select_idf():
	idf = 0
	while(idf > 3 or idf < 1):
		print("Choose one of the next IDF functions to use:")
		try:
			idf = int(raw_input("\t1: Unary\n\t2: Inverse\n\t3: Smoothed\n"))
		except:
			idf = 0
		if idf not in [1, 2, 3]:
			print("Selected mode not recognized. Please try again.")
	if idf == 1:
		return "unary"
	elif idf == 2:
		return "inv"
	elif idf == 3:
		return "smooth"

# Main
if __name__ == '__main__':
	# Create DocRetriever instance
	docs = loaders.load_docs(FILE)
	tf = select_tf()
	idf = select_idf()
	print("Initializing system. Please wait...")
	dc = DocRetriever(docs.values(), docs.keys(),
					  tf=tf, idf=idf)
	# Read default minimum score
	min_score = DEF_SCORE
	# Interactive system
	while(True):
		try:
			action = int(raw_input(ACTIONS))
		except:
			action = -1
		if action == 1:  # Perform query
			res = perform_query(dc, min_score)
			print_results(res, min_score)
		elif action == 2:  # Change minimum score
			mss = "Score changed from " + str(min_score)
			try:
				min_score = change_min_score()
				mss += " to " + str(min_score)
				print(mss)
				print("")
			except:
				print("Score unchanged\n")
		elif action == 3:  # Exit
			break
		else:
			print("Unknown action\n")

import pandas as pd
import re
import requests
import numpy as np
import time


#ID for What are Your Moves Tomorrow (pulled manually from the url)
#04/22/2021
#post_id = 'mvo1tm'
#04/23/2021
#post_id = 'mwdc90'
#04/26/2011
#post_id = 'myg8yx'
#04/27/2021
#post_id = 'mz6iks'
#04/28/2021
#post_id = 'mzx686'
#04/29/2021
post_id = 'n0ne5w'


#Pull all comment IDs from post
html = requests.get(f'https://api.pushshift.io/reddit/submission/comment_ids/{post_id}')
raw_comment_id_list = html.json()
all_comment_id_list = np.array(raw_comment_id_list['data'])

#Find the total number of chunks of comment IDs of length 1000
l = math.ceil(len(raw_comment_id_list['data'])/1000)

#Query for comment information
comments = []
for i in range(0,l):
    #Get the list of comment IDs in batches of 1000
    comment_id_list = ",".join(all_comment_id_list[i*1000:(i+1)*1000])
    #Query the Pushshift API for the comment data
    html = requests.get(f'https://api.pushshift.io/reddit/comment/search?ids={comment_id_list}&fields=id,author,created_utc,body,score')
    #The Pushshift API is rate limited, so if the API kicks back the request, the code waits 10 seconds and then tries again
    if html.status_code != 200:
        time.sleep(10)
        html = requests.get(f'https://api.pushshift.io/reddit/comment/search?ids={comment_id_list}&fields=id,author,created_utc,body,score')
    #Get the comment data in json format
    newcomments = html.json()
    #Concatenate with previously collected data
    comments = comments + newcomments['data']
    time.sleep(1)

#Save the data as a .csv file
pd.DataFrame.from_dict(comments).to_csv('waymt_4_29_21.csv', index = False)

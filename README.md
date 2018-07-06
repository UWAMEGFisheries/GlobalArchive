# GlobalArchiveLib

A library for interacting with the Global Archive repository

### Get the code

```bash
git clone https://ariell@bitbucket.org/ariell/galib.git
```

### Run the example
Example code is contained in: `R/examples/get_campaigns.R`. It is strongly
advised that you look at the source before running it as the comments explain
things and there are options for configuring it to do what you want to do.

To run the example code as is:
```bash
cd galib/R
Rscript examples/get_campaigns.R <USER_API_TOKEN>
```
Where `<USER_API_TOKEN>` is your API token for the GA API. This will download
all .csv and .txt files for all campaigns matching your query.

### Understanding the code

#### `R/examples/get_campaigns.R`
This is an example script that demonstrates how to get campaigns from the API.
The idea is that this script provides a starting point, and you can copy this
and take what you need out of it to make your own scripts / queries.

##### Setting your `USER_API_TOKEN`
You can either set this through command line argument as demonstrated above, or
configure it as a variable in the script.

##### Configuring where and what to download
The variable `MATCH_FILES` is passed to the `ga.download.campaign_files()`
function. That will filter the set of campaign files to download only the
matching ones. This is useful if you do not want to download all the .emobs
and/or .zip files. Some examples of what you can set:

Example 1: only download .csv and .txt files
```R
MATCH_FILES <- ".csv$|.txt$"
```
Example 2: only download files with *_Metadata.* in the filename
```R
MATCH_FILES <- "_Metadata."
```
Example 3: download all files
```R
MATCH_FILES <- NULL
```

##### Configuring the search query
The variable `q` is a JSON string that contains the search pattern for the API.
It is passed to the `ga.get.campaign.list()` function, which processes the
matched results. Some examples of search queries below (NB: this is not an exhaustive list, there are many more searches that you can do):

EXAMPLE 1: search for all campaigns matching pattern ( % = wildcard)
```R
q='{"filters":[{"name":"name","op":"like","val":"%_PointAddis_stereoBRUVs"}]}'
```
EXAMPLE 2: search for specific campaign by name
```R
q='{"filters":[{"name":"name","op":"eq","val":"2011-09_Barrow.PDS_stereoBRUVs"}]}'
```
EXAMPLE 3: search for all campaigns by user's email
```R
q='{"filters":[{"name":"user","op":"has","val":{"name":"email","op":"eq","val":"euan.harvey@curtin.edu.au"}}]}'
```
EXAMPLE 4: search for all campaigns from Project (note + for spaces)
```R
q='{"filters":[{"name":"project","op":"has","val":{"name":"name","op":"eq","val":"Deep+Water+FRDC"}}]}'
```
EXAMPLE 5: search for all campaigns from Collaboration (note + for spaces)
```R
q='{"filters":[{"name":"workgroups","op":"any","val":{"name":"name","op":"eq","val":"NSW+MER+BRUVS"}}]}'
```
EXAMPLE 6: search for all campaigns from Collaboration with wildcard search (%=wildcarg, ilike=case insensitive)
```R
q='{"filters":[{"name":"workgroups","op":"any","val":{"name":"name","op":"ilike","val":"nsw%bruvs"}}]}'
```
EXAMPLE 7: get all campaigns that my user account has access to
```R
q=""
```

#### R/galib.R
This is a library containing convenience functions which abstract the GA API
interactions making it quick and easy to get data from the API.

```
TODO: documentation still to come
```

### TODO

* Turn galib.R into an R package to make it easier
* Implement the many other API functions that are not yet included in galib.R

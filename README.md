# GlobalArchiveLib #

A library for interacting with the Global Archive repository

### How do I get set up? ###

```
git clone https://ariell@bitbucket.org/ariell/galib.git
```

Example code is contained in: `R/examples/get_campaigns.R`. This file sources the `R/galib.R` file which contains all the necessary functions required to interact with the GA API.

To run the example code:
```
cd galib/R
Rscript examples/get_campaigns.R <MY_USER_API_TOKEN>
```

Where `<MY_USER_API_TOKEN>` is your API token for the GA API.

### TODO ###

* Turn galib.R into an R package to make it easier
* Implement the many other API functions that are not yet included in galib.R
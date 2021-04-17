

library(jsonlite)
library(dplyr)
library(stringr)
library(igraph)
library(qgraph)

# country data, source:
# https://github.com/dariusk/corpora/blob/master/data/geography/countries.json
countries <- data.frame(country=unlist(read_json("countries.json"))[-1],
                        row.names=NULL)

# get first and last letters
countries <- countries %>%
  mutate(first = tolower(str_replace(country, "^(.).+", "\\1")),
         last  = tolower(str_replace(country, ".+(.)$", "\\1")))

countries_long <- countries

# refine to start and end letter combinations
countries <- unique(countries[, c("first", "last")])
countries$name <- paste0(countries$first, countries$last)

build_graph <- function(dat){
  # make adjacency matrix
  adj <- matrix(0, nrow(dat), nrow(dat))
  for(i in 1:nrow(dat)){
    this_last <- dat$last[i]
    adj[i, ] <- dat$first == this_last
  }
  # name rows/cols
  colnames(adj) <- rownames(adj) <- dat$name

  # construct the graph object
  graph_from_adjacency_matrix(adj, diag=FALSE, mode="directed")
}

gr <- build_graph(countries)

# function to find entries that we can't get back to/out of
unconnected_places <- function(x, graphy){
  if(length(incident(graphy, V(graphy)[name==x], "in"))==0 ||
     length(incident(graphy, V(graphy)[name==x], "out"))==0){
    return(x)
  }
}

# find the names
rm_names1 <- unlist(lapply(countries$name, unconnected_places, graphy=gr))
# remove them
countries <- countries[!(countries$name %in% rm_names1), ]
# rebuild the graph
gr <- build_graph(countries)

# we do this twice, since we make new cul-de-sacs the first time
rm_names2 <- unlist(lapply(countries$name, unconnected_places, graphy=gr))
countries <- countries[!(countries$name %in% rm_names2), ]
gr <- build_graph(countries)

# now plot the graph
e <- get.edgelist(gr, names=FALSE)
l <- qgraph.layout.fruchtermanreingold(e, vcount=vcount(gr))
plot(gr, layout=l, vertex.size=4, edge.arrow.size=0.25, edge.width=0.5)




# how do we get back home?
met_path <- function(this_node, graphy, plot=FALSE){

  first_l<- str_extract(this_node, "^.")
  last_l <- str_extract(this_node, ".$")

  # the last place we want to be before we get home has the same last letter
  # as the first letter in the country name
  endpoints <- countries$name[countries$last == first_l]
  # the first place we go will have the same first letter as the last letter
  # in our current country name
  startpoints <- countries$name[countries$first == last_l]

  # simplest possible path to one node and back
  # don't bother doing all that computation
  if(any(startpoints %in% endpoints)){
    return(c(this_node, startpoints[startpoints %in% endpoints][1]))
  }

  allpaths <- list()
  allcosts <- c()
  for(i in 1:length(startpoints)){
    # get this start point
    st <- startpoints[i]

    # find the shortest path between the start point and all end points
    sp <- shortest_paths(graphy, from=V(graphy)[name==st],
                         to=V(graphy)[name %in% endpoints],
                         output="both")

    # which was the shortest ?
    bpi <- which.min(lapply(sp$epath, length))

    # get the best of these paths, edges and vertices
    epath <- sp$epath[[bpi]]
    vpath <- sp$vpath[[bpi]]

    allpaths[[i]] <- list(epath=epath, vpath=vpath)
    allcosts <- c(allcosts, length(epath))
  }

  # which was the shortest ?
  bpi <- which.min(allcosts)

  # get the best of these paths, edges and vertices
  epath <- allpaths[[bpi]]$epath
  vpath <- allpaths[[bpi]]$vpath

  if(plot){
    # Generate edge color variable to plot the path:
    ecol <- rep("gray80", ecount(graphy))
    ecol[epath] <- "orange"

    # Generate edge width variable to plot the path:
    ew <- rep(2, ecount(graphy))
    ew[epath] <- 4

    # Generate node color variable to plot the path:
    vcol <- rep("gray40", vcount(graphy))
    vcol[vpath] <- "gold"

    # colour the start node too
    vcol[V(graphy)[name==this_node]] <- "green"
    # and start/end edges
    ind <- attr(E(graphy), "vnames")==paste0(vpath[length(vpath)]$name, "|",
                                             this_node)
    ew[ind] <- 4
    ecol[ind] <- "orange"
    ind <- attr(E(graphy), "vnames")==paste0(this_node, "|",
                                             vpath[1]$name)
    ew[ind] <- 4
    ecol[ind] <- "orange"

    # make the plot
    plot(graphy, vertex.color=vcol, edge.color=ecol,
         edge.width=ew, vertex.size=4, edge.arrow.size=0.25)
  }

  # return the path
  c(this_node, vpath$name)
}

# run the above function over all the countries
ll <- lapply(countries$name, get_path, graphy=gr)
names(ll) <- countries$name


# format a markdown table to put in README.md
ll <- lapply(ll, function(x) c(x, rep(" ", c(6-length(x)))))

sink("tab.md")
aa <- lapply(ll, function(x){
  x <- lapply(x, function(x){
    paste(subset(countries_long, first==str_extract(x, "^.") &
                 last==str_extract(x, ".$"))$country,
          collapse="<br/>")
  })
  cat("|", paste(x, collapse=" | "), "|\n")
})
sink()


# which are the "bad" names that don't work with this game?
paste(unlist(lapply(c(rm_names1, rm_names2), function(x){
  subset(countries_long, first==str_extract(x, "^.") &
         last==str_extract(x, ".$"))$country
})), collapse=", ")

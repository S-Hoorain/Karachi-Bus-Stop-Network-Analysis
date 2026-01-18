# Install / load packages
if (!require(igraph)) install.packages("igraph")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(dplyr)) install.packages("dplyr")

library(igraph)
library(ggplot2)
library(dplyr)

# Loading data and creating directed graph
edges = read.csv("karachi_bus_network_edge_list.csv", stringsAsFactors = FALSE)
nodes_data = read.csv("karachi_bus_network_node_data.csv", stringsAsFactors = FALSE)

karachi_bus_network = graph_from_data_frame(edges, directed = TRUE, vertices = nodes_data)

# Adding coordinates if not already included
if (is.null(V(karachi_bus_network)$longi) || is.null(V(karachi_bus_network)$lati)) {
  nodes = V(karachi_bus_network)$name
  longi_values = nodes_data$long[match(nodes, nodes_data$node)]
  lati_values  = nodes_data$latit[match(nodes, nodes_data$node)]
  V(karachi_bus_network)$longi = longi_values
  V(karachi_bus_network)$lati  = lati_values
}

# Section 1: global metrics and centralities

# we use cat to print with a string concatenation.
cat("Nodes:", vcount(karachi_bus_network), "\n")
cat("Edges:", ecount(karachi_bus_network), "\n")


# In-degree, Out-degree
in_deg  = degree(karachi_bus_network, mode = "in")
out_deg = degree(karachi_bus_network, mode = "out")
tot_deg = degree(karachi_bus_network, mode = "all")


# Avg.degree
mean_in = mean(in_deg)
mean_out = mean(out_deg)
mean_total = mean(tot_deg)
avg_degree = mean_in + mean_out

cat("\nMean In-degree:", mean_in, "\n")
cat("Mean Out-degree:", mean_out, "\n")
cat("Average Degree (In + Out):", avg_degree, "\n\n")

# Density
network_density = edge_density(karachi_bus_network)
cat("Network Density:", network_density, "\n")

# Clustering coefficient
global_cc = transitivity(karachi_bus_network, type = "global")
avg_local_cc = transitivity(karachi_bus_network, type = "average")
cat("Global Clustering Coefficient:", global_cc, "\n")
cat("Average Local Clustering Coefficient:", avg_local_cc, "\n")

# Path length and diameter
# using try catch here just in case graph has unreachable nodes.
avg_path_length = tryCatch({
  mean_distance(karachi_bus_network, directed = TRUE, unconnected = TRUE)
}, error = function(e) { NA })
network_diameter = tryCatch({
  diameter(karachi_bus_network, directed = TRUE, unconnected = TRUE)
}, error = function(e) { NA })
cat("Average Path Length:", avg_path_length, "\n")
cat("Network Diameter:", network_diameter, "\n")

# Betweenness centrality
btw = betweenness(karachi_bus_network, directed = TRUE, normalized = TRUE)

# Closeness centrality
cls_in = closeness(karachi_bus_network, mode = "in", normalized = TRUE)
cls_out = closeness(karachi_bus_network, mode = "out", normalized = TRUE)

# Eigenvector centrality
eig = eigen_centrality(karachi_bus_network, directed = TRUE)$vector

# Adding everything into vertex attributes
V(karachi_bus_network)$indegree   = in_deg
V(karachi_bus_network)$outdegree  = out_deg
V(karachi_bus_network)$totdegree  = degree(karachi_bus_network, mode = "all")
V(karachi_bus_network)$betweenness= btw
V(karachi_bus_network)$closeness_in  = cls_in
V(karachi_bus_network)$closeness_out = cls_out
V(karachi_bus_network)$eigenvector   = eig
V(karachi_bus_network)$pagerank      = page_rank(karachi_bus_network, directed = TRUE)$vector

# Compiling results into dataframe to print top 5s altogether later
centrality_df = data.frame(
  StopName     = V(karachi_bus_network)$name,
  InDegree     = V(karachi_bus_network)$indegree,
  OutDegree    = V(karachi_bus_network)$outdegree,
  TotalDegree  = V(karachi_bus_network)$totdegree,
  InCloseness  = V(karachi_bus_network)$closeness_in,
  OutCloseness = V(karachi_bus_network)$closeness_out,
  Betweenness  = V(karachi_bus_network)$betweenness,
  Eigenvector  = V(karachi_bus_network)$eigenvector,
  PageRank     = V(karachi_bus_network)$pagerank,
  stringsAsFactors = FALSE
)

# Section 3: Printing top 5's of the bus network
# Print Top-5 rankings
cat("\n--- Top 5 by In-Degree ---\n")
print(head(arrange(centrality_df, desc(InDegree)), 5))

cat("\n--- Top 5 by Out-Degree ---\n")
print(head(arrange(centrality_df, desc(OutDegree)), 5))

cat("\n--- Top 5 by Betweenness ---\n")
print(head(arrange(centrality_df, desc(Betweenness)), 5))

cat("\n--- Top 5 by In-Closeness ---\n")
print(head(arrange(centrality_df, desc(InCloseness)), 5))

cat("\n--- Top 5 by Out-Closeness ---\n")
print(head(arrange(centrality_df, desc(OutCloseness)), 5))

cat("\n--- Top 5 by Eigenvector ---\n")
print(head(arrange(centrality_df, desc(Eigenvector)), 5))

cat("\n--- Top 5 by PageRank ---\n")
print(head(arrange(centrality_df, desc(PageRank)), 5))

# ------------------------------------------------------
# Export for later
write.csv(centrality_df, "karachi_centrality_measures.csv", row.names = FALSE)
cat("\nCentrality measures written to karachi_centrality_measures.csv\n")
# ------------------------------------------------------
# Save Top-5 rankings to separate CSVs
write.csv(head(arrange(centrality_df, desc(TotalDegree)), 5),
          "top5_indegree.csv", row.names = FALSE)

write.csv(head(arrange(centrality_df, desc(InDegree)), 5),
          "top5_indegree.csv", row.names = FALSE)

write.csv(head(arrange(centrality_df, desc(OutDegree)), 5),
          "top5_outdegree.csv", row.names = FALSE)

write.csv(head(arrange(centrality_df, desc(Betweenness)), 5),
          "top5_betweenness.csv", row.names = FALSE)

write.csv(head(arrange(centrality_df, desc(InCloseness)), 5),
          "top5_incloseness.csv", row.names = FALSE)

write.csv(head(arrange(centrality_df, desc(OutCloseness)), 5),
          "top5_outcloseness.csv", row.names = FALSE)

write.csv(head(arrange(centrality_df, desc(Eigenvector)), 5),
          "top5_eigenvector.csv", row.names = FALSE)

write.csv(head(arrange(centrality_df, desc(PageRank)), 5),
          "top5_pagerank.csv", row.names = FALSE)

cat("\nTop 5 rankings written to separate CSV files.\n")

# Section 
# Quick degree distribution
degree_dist = degree.distribution(karachi_bus_network)


# Simple visualization so we can see the patterns in the bus stops degree
# Color nodes by InDegree - OutDegree difference (positive => more incoming)
diff_in_out = centrality_df$InDegree - centrality_df$OutDegree
V(karachi_bus_network)$color = ifelse(diff_in_out > 0, "tomato", ifelse(diff_in_out < 0, "steelblue", "gold"))
V(karachi_bus_network)$size  = 2 + (centrality_df$TotalDegree / max(1, centrality_df$TotalDegree)) * 6

# Plot (force-directed) showing hubs vs sinks
set.seed(123)
plot(karachi_bus_network,
     layout = layout_with_fr,
     vertex.color = V(karachi_bus_network)$color,
     vertex.size = V(karachi_bus_network)$size *2,
     vertex.label = NA,
     edge.size = 0.1,
     edge.color = "gray80",
     main = "Karachi Bus Network: red = more in-degree (destinations), blue = more out-degree (origins)"
)

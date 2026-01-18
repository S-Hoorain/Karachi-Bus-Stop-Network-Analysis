# Karachi Bus Network Analysis 🚌

## Overview
This project performs a **Social Network Analysis (SNA)** of the Karachi bus system. By modeling bus stops as nodes and routes as directed edges, we analyze the structural properties of the public transport network.

The goal is to identify critical transport hubs, bottlenecks, and the overall flow efficiency of the network using Graph Theory.

## Key Metrics Calculated
The analysis computes the following centrality measures for every bus stop:
* **Betweenness Centrality:** Identifies "bridge" stops that control flow between different parts of the city.
* **PageRank & Eigenvector Centrality:** Determines the most influential stops based on their connections to other important stops.
* **Degree Centrality (In/Out):** Highlights major terminals (sources) versus major destinations (sinks).

## Visualizations
The project generates a force-directed graph visualization:
* **Red Nodes:** Net Destintions (More buses arrive than leave).
* **Blue Nodes:** Net Origins (More buses leave than arrive).
* **Node Size:** Proportional to the total traffic (Degree) of the stop.

## Repository Structure
* `data/`: Contains the edge list and node attributes (coordinates).
* `R/`: The primary R scripts.
* `output/`: Generated CSV reports, Analysis report and network visualizations.

## Getting Started

### Prerequisites
* R (4.0+)
* RStudio

### Installation
1. Clone the repository.
2. Open the `.Rproj` file in RStudio.
3. Install dependencies:
   ```r
   install.packages("pacman")
   source("main_analysis.R") # This will automatically install other missing packages

### Usage
Run the main script to generate the reports:
source("main_analysis.R")
Results will appear in the output/ folder.

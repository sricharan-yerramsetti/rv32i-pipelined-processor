/* Freestanding Bellman-Ford shortest path algorithm for RV32I bare-metal core.
 * No libc, no stdio, no malloc — everything is static arrays so the results
 * land in known global memory addresses you can inspect directly in MEM[]
 * after simulation.
 *
 * Graph is hardcoded: 5 vertices, 8 directed weighted edges.
 * After main() finishes, `dist[]` holds the shortest distance from vertex 0
 * to every other vertex. `done` is set to 1 (0xFFFFFFFF signals no
 * negative-weight cycle detected; 0 would mean one exists).
 */

#define V 5   /* number of vertices */
#define E 8   /* number of edges */

#define INF 1000000

struct Edge {
    int src;
    int dst;
    int weight;
};

/* Hardcoded graph: adjust as needed */
struct Edge edges[E] = {
    {0, 1, 6},
    {0, 2, 7},
    {1, 2, 8},
    {1, 3, 5},
    {1, 4, -4},
    {2, 3, -3},
    {2, 4, 9},
    {3, 1, -2}
};

/* Result arrays — inspect these in MEM.hex / simulation waveform */
volatile int dist[V];
volatile int no_negative_cycle;   /* 1 = safe, 0 = negative cycle detected */

int main(void) {
    int i, j;

    /* Step 1: initialize distances */
    for (i = 0; i < V; i = i + 1) {
        dist[i] = INF;
    }
    dist[0] = 0;   /* source vertex */

    /* Step 2: relax all edges V-1 times */
    for (i = 0; i < V - 1; i = i + 1) {
        for (j = 0; j < E; j = j + 1) {
            int u = edges[j].src;
            int v = edges[j].dst;
            int w = edges[j].weight;
            if (dist[u] != INF) {
                if (dist[u] + w < dist[v]) {
                    dist[v] = dist[u] + w;
                }
            }
        }
    }

    /* Step 3: check for negative-weight cycles */
    no_negative_cycle = 1;
    for (j = 0; j < E; j = j + 1) {
        int u = edges[j].src;
        int v = edges[j].dst;
        int w = edges[j].weight;
        if (dist[u] != INF) {
            if (dist[u] + w < dist[v]) {
                no_negative_cycle = 0;
            }
        }
    }

    /* Nowhere to "return" to on bare metal — spin forever so the
     * simulation has a stable final state to inspect. */
    while (1) {
        /* halt */
    }

    return 0;
}

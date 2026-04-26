import networkx as nx
import matplotlib.pyplot as plt
import numpy as np
import math

# --- KONFIGURATION (SVG EDITION) ---
N_NODES = 300            # Anzahl der "Neuronen"-Knotenpunkte
CONNECT_RADIUS = 0.20   # Maximale Distanz für eine Verbindung (0.0 bis 1.0)
WIDTH, HEIGHT = 10, 10 # Canvas-Größe in Zoll (beeinflusst die Basis-Linienstärke)

# Farben
COLOR_LINE = 'white'     # Rein weisse Linien
COLOR_NODE = 'white'     # Rein weisse Knotenpunkte
COLOR_BG_DARK = 'black'  # Schwarzer Hintergrund für Version 1

# --- START DER GENERIERUNG ---
print("Generiere zufälliges Netzwerk für Vektorexport...")

# 1. Erstelle ein geometrisches Zufalls-Netzwerk
G = nx.random_geometric_graph(n=N_NODES, radius=CONNECT_RADIUS)

# Hole die Positionen der Knoten
pos = nx.get_node_attributes(G, 'pos')

# 2. Plot-Funktion definieren (um sie zweimal aufzurufen)
def generate_and_save_plot(filename, background_color, transparent):
    """Generiert den Plot und speichert ihn als SVG."""
    fig, ax = plt.subplots(figsize=(WIDTH, HEIGHT), dpi=100)
    
    # Hintergrund setzen
    fig.patch.set_facecolor(background_color)
    ax.set_facecolor(background_color)
    if transparent:
        # Wenn transparent, Setze Alpha-Werte auf 0
        fig.patch.set_alpha(0)
        ax.patch.set_alpha(0)

    # Achsen verstecken
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')

    print(f"Rendere {G.number_of_edges()} Vektor-Verbindungen...")

    # 3. Iteriere über alle Verbindungen (Edges), um sie zu zeichnen
    for u, v in G.edges():
        x = [pos[u][0], pos[v][0]]
        y = [pos[u][1], pos[v][1]]
        
        dist = math.sqrt((x[0]-x[1])**2 + (y[0]-y[1])**2)
        norm_dist = dist / CONNECT_RADIUS # Normalisierte Distanz 0-1
        
        # --- VARIATION BERECHNEN (Dicke und Helligkeit) ---
        # numpy.interp(Wert, [von_min, von_max], [zu_min, zu_max])
        
        # Linienstärke: Nah = 2.0pt, Fern = 0.3pt (als Vektor-Basis)
        linewidth = np.interp(norm_dist, [0, 1], [2.0, 0.3])
        
        # Helligkeit/Alpha: Nah = 1.0 (opak), Fern = 0.1 (sehr transparent)
        alpha = np.interp(norm_dist, [0, 1], [1.0, 0.1])
        
        # Zeichne EINE reine Vektor-Linie
        ax.plot(x, y, color=COLOR_LINE, linewidth=linewidth, alpha=alpha, zorder=1)

    # 4. Iteriere über alle Knoten, um sie zu zeichnen (Optionale kleine Kreise)
    print("Zeichne Knotenpunkte...")
    for node in G.nodes():
        # Kleine Kreise als Knoten
        node_size = 3
        ax.scatter(pos[node][0], pos[node][1], s=node_size, color=COLOR_NODE, alpha=1.0, zorder=2, edgecolors='none')

    # 5. Speichern als SVG
    print(f"Speichere Bild als SVG: {filename}...")
    plt.savefig(filename, format='svg', bbox_inches='tight', pad_inches=0)
    plt.close(fig) # Plot schließen, um Speicher freizugeben

# --- AUSFÜHRUNG ---

# Version 1: Schwarzer Hintergrund zum Anschauen
generate_and_save_plot("netzwerk_schwarz.svg", COLOR_BG_DARK, transparent=False)

# Version 2: Völlig transparent für den Import
generate_and_save_plot("netzwerk_transparent.svg", 'none', transparent=True)

print("\nFertig! Beide SVG-Dateien wurden generiert.")
/**
* Modèle de simulation BFS (Breadth-First Search) - Version avec Displays Séparés
* Auteur: YVALTT
* Description: Simulation d'un algorithme de recherche en largeur sur un graphe de points
* Amélioration: Séparation des informations dans des displays dédiés
*/

model BFS_simulation

global {
    // ===== PARAMÈTRES DE LA SIMULATION =====
    int nb_points <- 50 parameter: "Nombre de points (N)" category: "Configuration" min: 10 max: 200;
    int nb_voisins <- 4 parameter: "Nombre de voisins (n)" category: "Configuration" min: 2 max: 8;
    int nb_obstacles <- 10 parameter: "Nombre d'obstacles" category: "Configuration" min: 0 max: 30;
    float rayon_obstacle <- 5.0 parameter: "Rayon des obstacles" category: "Configuration" min: 2.0 max: 10.0;
    
    // ===== NOUVEAUX PARAMÈTRES VISUELS =====
    bool animation_lente <- true parameter: "Animation lente" category: "Visuel";
    bool afficher_distances <- true parameter: "Afficher distances" category: "Visuel";
    bool afficher_connexions <- true parameter: "Afficher connexions" category: "Visuel";
    bool effet_vague <- true parameter: "Effet de vague BFS" category: "Visuel";
    
    // ===== VARIABLES GLOBALES =====
    noeud point_depart;
    noeud point_destination;
    list<noeud> file_attente;
    list<noeud> noeuds_visites;
    bool recherche_terminee <- false;
    list<noeud> chemin_final;
    list<geometry> obstacles;
    
    // ===== NOUVELLES VARIABLES POUR L'ANIMATION =====
    int etape_actuelle <- 0;
    noeud noeud_en_exploration;
    list<noeud> niveaux_bfs <- [];
    int delai_animation <- 0;
    
    // ===== STATISTIQUES =====
    int nb_connexions_totales <- 0;
    float temps_debut;
    float temps_fin;
    
    init {
        write "=== INITIALISATION DE LA SIMULATION BFS AMÉLIORÉE ===";
        temps_debut <- machine_time / 1000.0;
        
        // ÉTAPE 1 : Création des obstacles avec formes variées
        write "Création de " + nb_obstacles + " obstacles...";
        loop i from: 0 to: nb_obstacles - 1 {
            point centre <- {rnd(90.0) + 5, rnd(90.0) + 5};
            geometry obs;
            
            // Variation des formes d'obstacles
            if (rnd(100) < 70) {
                obs <- circle(rayon_obstacle + rnd(2.0)) at_location centre;
            } else {
                float largeur <- rayon_obstacle * 2 + rnd(3.0);
                float hauteur <- rayon_obstacle * 2 + rnd(3.0);
                obs <- rectangle(largeur, hauteur) at_location centre;
            }
            add obs to: obstacles;
        }
        
        // ÉTAPE 2 : Création des nœuds avec positionnement optimisé
        write "Création de " + nb_points + " nœuds...";
        create noeud number: nb_points {
            bool position_valide <- false;
            int tentatives <- 0;
            
            loop while: !position_valide and tentatives < 100 {
                location <- {rnd(95.0) + 2.5, rnd(95.0) + 2.5};
                position_valide <- true;
                
                // Vérifier distance minimale avec obstacles
                loop obs over: obstacles {
                    geometry zone_noeud <- circle(1.5) at_location location;
                    if (obs intersects zone_noeud) {
                        position_valide <- false;
                        break;
                    }
                }
                
                // Éviter les positions trop proches d'autres nœuds
                if (position_valide) {
                    ask noeud - self {
                        if (self distance_to myself < 3.0) {
                            position_valide <- false;
                        }
                    }
                }
                tentatives <- tentatives + 1;
            }
            
            // Attributs visuels initiaux
            taille_base <- 1.5 + rnd(0.5);
            pulsation <- rnd(360.0);
        }
        
        // ÉTAPE 3 : Construction du graphe avec métriques
        write "Construction du graphe (connexion des voisins)...";
        ask noeud {
            list<noeud> autres_noeuds <- noeud - self;
            autres_noeuds <- autres_noeuds sort_by (each distance_to self);
            
            int voisins_connectes <- 0;
            loop candidat over: autres_noeuds {
                if (voisins_connectes >= nb_voisins) { break; }
                
                geometry ligne <- line([location, candidat.location]);
                bool obstacle_present <- false;
                
                loop obs over: obstacles {
                    if (ligne intersects obs) {
                        obstacle_present <- true;
                        break;
                    }
                }
                
                if (!obstacle_present) {
                    add candidat to: voisins;
                    voisins_connectes <- voisins_connectes + 1;
                    nb_connexions_totales <- nb_connexions_totales + 1;
                }
            }
        }
        
        // ÉTAPE 4 : Sélection intelligente des points de départ et destination
        write "Sélection optimisée du départ et de la destination...";
        
        // Point de départ dans le premier tiers
        list<noeud> candidats_depart <- noeud where (each.location.x < 33);
        if (empty(candidats_depart)) { candidats_depart <- noeud; }
        point_depart <- one_of(candidats_depart);
        point_depart.est_depart <- true;
        
        // Point de destination dans le dernier tiers
        list<noeud> candidats_destination <- (noeud - point_depart) where (each.location.x > 66);
        if (empty(candidats_destination)) { candidats_destination <- noeud - point_depart; }
        point_destination <- one_of(candidats_destination);
        point_destination.est_destination <- true;
        
        // ÉTAPE 5 : Initialisation BFS
        file_attente <- [point_depart];
        noeuds_visites <- [point_depart];
        point_depart.visite <- true;
        point_depart.distance_depuis_depart <- 0;
        point_depart.niveau_bfs <- 0;
        
        write "Distance euclidienne départ-destination : " + (point_depart distance_to point_destination) with_precision 2;
        write "=== DÉBUT DE LA RECHERCHE BFS ===";
    }
    
    // ===== RÉFLEXE PRINCIPAL AVEC ANIMATION =====
    reflex executer_bfs when: !recherche_terminee and !empty(file_attente) {
        // Gestion de l'animation
        if (animation_lente) {
            delai_animation <- delai_animation + 1;
            if (delai_animation < 3) { return; }
            delai_animation <- 0;
        }
        
        noeud noeud_actuel <- first(file_attente);
        remove noeud_actuel from: file_attente;
        noeud_en_exploration <- noeud_actuel;
        etape_actuelle <- etape_actuelle + 1;
        
        write "Étape " + etape_actuelle + " - Exploration : " + noeud_actuel + 
              " (distance: " + noeud_actuel.distance_depuis_depart + ")";
        
        // Vérification destination
        if (noeud_actuel = point_destination) {
            recherche_terminee <- true;
            temps_fin <- machine_time / 1000.0;
            noeud_en_exploration <- nil;
            
            write "=== DESTINATION TROUVÉE ! ===";
            write "Temps d'exécution : " + (temps_fin - temps_debut) with_precision 3 + " secondes";
            write "Étapes de recherche : " + etape_actuelle;
            write "Distance optimale : " + noeud_actuel.distance_depuis_depart + " nœuds";
            
            // Reconstruction du chemin
            noeud n <- point_destination;
            loop while: n != nil {
                add n to: chemin_final;
                n.dans_chemin <- true;
                n <- n.parent;
            }
            chemin_final <- reverse(chemin_final);
            return;
        }
        
        // Exploration des voisins avec effet de vague
        ask noeud_actuel {
            loop voisin over: voisins {
                if (!voisin.visite) {
                    voisin.visite <- true;
                    voisin.parent <- self;
                    voisin.distance_depuis_depart <- distance_depuis_depart + 1;
                    voisin.niveau_bfs <- distance_depuis_depart + 1;
                    voisin.moment_visite <- etape_actuelle;
                    
                    add voisin to: file_attente;
                    add voisin to: noeuds_visites;
                }
            }
        }
    }
    
    reflex fin_recherche when: empty(file_attente) and !recherche_terminee {
        recherche_terminee <- true;
        temps_fin <- machine_time / 1000.0;
        noeud_en_exploration <- nil;
        
        write "=== AUCUN CHEMIN TROUVÉ ===";
        write "Temps d'exécution : " + (temps_fin - temps_debut) with_precision 3 + " secondes";
        write "Nœuds explorés : " + length(noeuds_visites) + "/" + nb_points;
    }
    
    // ===== RÉFLEXE D'ANIMATION =====
    reflex animation {
        ask noeud {
            // Animation de pulsation
            pulsation <- pulsation + 5.0;
            if (pulsation > 360) { pulsation <- pulsation - 360; }
            
            // Effet de vague BFS
            if (effet_vague and visite and !recherche_terminee) {
                float phase <- (etape_actuelle - moment_visite) * 30.0;
                intensite_vague <- cos(phase) * 0.3 + 0.7;
            } else {
                intensite_vague <- 1.0;
            }
        }
    }
}

// ===== ESPÈCE NOEUD AMÉLIORÉE =====
species noeud {
    // === Attributs existants ===
    list<noeud> voisins;
    bool visite <- false;
    noeud parent <- nil;
    int distance_depuis_depart <- -1;
    bool est_depart <- false;
    bool est_destination <- false;
    
    // === Nouveaux attributs visuels ===
    float taille_base <- 1.5;
    float pulsation <- 0.0;
    int niveau_bfs <- -1;
    int moment_visite <- 0;
    bool dans_chemin <- false;
    float intensite_vague <- 1.0;
    
    // === ASPECT PRINCIPAL AMÉLIORÉ ===
    aspect default {
        // Connexions avec dégradé selon la distance
        if (afficher_connexions) {
            loop v over: voisins {
                rgb couleur_connexion <- visite and v.visite ? 
                    rgb(100, 150, 255, 100) : rgb(200, 200, 200, 50);
                float epaisseur <- visite and v.visite ? 1.0 : 0.3;
                draw line([location, v.location]) color: couleur_connexion width: epaisseur;
            }
        }
        
        // Calcul de la taille avec animation
        float taille_finale <- taille_base;
        rgb couleur_finale <- #blue;
        
        if (est_depart) {
            taille_finale <- 4.0 + sin(pulsation) * 0.5;
            couleur_finale <- #green;
            draw circle(taille_finale + 1) color: rgb(0, 255, 0, 50);
        } else if (est_destination) {
            taille_finale <- 4.0 + cos(pulsation) * 0.5;
            couleur_finale <- #red;  
            draw circle(taille_finale + 1) color: rgb(255, 0, 0, 50);
        } else if (self = noeud_en_exploration) {
            taille_finale <- 3.5 + sin(pulsation * 2) * 0.8;
            couleur_finale <- #yellow;
            draw circle(taille_finale + 2) color: rgb(255, 255, 0, 80);
        } else if (dans_chemin) {
            taille_finale <- 3.0 + cos(pulsation) * 0.3;
            couleur_finale <- #purple;
        } else if (visite) {
            int rouge <- 100 + (niveau_bfs * 20) min 255;
            int vert <- 150 + (niveau_bfs * 10) min 255;
            int bleu <- 255 - (niveau_bfs * 15) max 100;
            couleur_finale <- rgb(rouge, vert, bleu, 200);
            taille_finale <- (2.0 + niveau_bfs * 0.1) * intensite_vague;
        }
        
        // Dessin du nœud principal
        draw circle(taille_finale) color: couleur_finale border: #black width: 0.5;
        
        // Indicateur de niveau/distance
        if (afficher_distances and visite and distance_depuis_depart >= 0 and !est_depart) {
            draw string(distance_depuis_depart) 
                color: #white size: 8 font: font("Arial", 8, #bold)
                at: location;
        }
        
        // Labels pour départ/destination
        if (est_depart) {
            draw "START" color: #darkgreen size: 10 font: font("Arial", 10, #bold)
                at: location + {0, -8};
        } else if (est_destination) {
            draw "GOAL" color: #darkred size: 10 font: font("Arial", 10, #bold)
                at: location + {0, -8};
        }
    }
    
    // === ASPECT CHEMIN FINAL ===
    aspect chemin_final {
        if (dans_chemin and chemin_final != nil) {
            int position <- chemin_final index_of self;
            if (position >= 0 and position < length(chemin_final) - 1) {
                noeud suivant <- chemin_final[position + 1];
                
                // Ligne de chemin animée
                draw line([location, suivant.location]) 
                    color: rgb(148, 0, 211, 200) width: 3.0;
                
                // Flèche directionnelle (triangle simple)
                point milieu <- (location + suivant.location) / 2;
                draw triangle(1.5) color: #purple at: milieu;
            }
        }
    }
}

// ===== EXPÉRIENCE AVEC DISPLAYS SÉPARÉS =====
experiment BFS_Enhanced_Experiment type: gui {
    parameter "Nombre de points (N)" var: nb_points;
    parameter "Nombre de voisins (n)" var: nb_voisins;
    parameter "Nombre d'obstacles" var: nb_obstacles;
    parameter "Rayon des obstacles" var: rayon_obstacle;
    parameter "Animation lente" var: animation_lente;
    parameter "Afficher distances" var: afficher_distances;
    parameter "Afficher connexions" var: afficher_connexions;
    parameter "Effet de vague" var: effet_vague;
    
    output {
        // ===== DISPLAY PRINCIPAL : GRAPHE SEUL =====
        display "🔍 Graphe BFS" type: 2d background: rgb(20, 25, 40) refresh: every(1#cycle) {
            
            // COUCHE 1 : Grille de fond
            graphics "grille" transparency: 0.9 {
                loop i from: 0 to: 10 {
                    draw line([{i*10, 0}, {i*10, 100}]) color: rgb(60, 60, 80);
                    draw line([{0, i*10}, {100, i*10}]) color: rgb(60, 60, 80);
                }
            }
            
            // COUCHE 2 : Zone d'exploration (enveloppe convexe)
            graphics "zone_exploration" transparency: 0.7 {
                if (length(noeuds_visites) >= 3) {
                    list<point> points <- noeuds_visites collect each.location;
                    geometry zone <- convex_hull(polygon(points));
                    draw zone color: rgb(0, 100, 200, 30) border: rgb(0, 150, 255, 100);
                }
            }
            
            // COUCHE 3 : Obstacles avec ombres
            graphics "obstacles" {
                loop obs over: obstacles {
                    // Ombre
                    geometry ombre <- obs translated_by {1, 1};
                    draw ombre color: rgb(0, 0, 0, 50);
                    // Obstacle principal
                    draw obs color: rgb(80, 80, 80) border: rgb(120, 120, 120) width: 1.5;
                }
            }
            
            // COUCHE 4 : Nœuds et connexions
            species noeud aspect: default;
            
            // COUCHE 5 : Chemin final
            species noeud aspect: chemin_final;
            
            // COUCHE 6 : Message d'état central uniquement
            graphics "etat" {
                if (recherche_terminee) {
                    if (!empty(chemin_final)) {
                        draw "🎯 CHEMIN TROUVÉ !" 
                            color: #lime size: 18 font: font("Arial", 18, #bold)
                            at: {50, 8};
                    } else {
                        draw "❌ AUCUN CHEMIN POSSIBLE" 
                            color: #red size: 18 font: font("Arial", 18, #bold)
                            at: {50, 8};
                    }
                } else if (noeud_en_exploration != nil) {
                    draw "🔍 Exploration en cours..." 
                        color: #yellow size: 16 font: font("Arial", 16, #bold)
                        at: {50, 8};
                }
            }
        }
        
        // ===== DISPLAY LÉGENDE SÉPARÉ =====
        display "📋 Légende" type: 2d background: rgb(40, 45, 60) refresh: every(5#cycle) 
                 synchronized: false {
            graphics "legende_complete" {
                // Titre principal
                draw "LÉGENDE BFS" color: #white size: 16 font: font("Arial", 16, #bold)
                    at: {50, 8};
                
                // Ligne de séparation
                draw line([{10, 12}, {90, 12}]) color: rgb(255, 255, 255, 150) width: 2;
                
                float y_pos <- 18;
                float x_icon <- 20;
                float x_text <- 30;
                
                // Section Nœuds
                draw "NŒUDS:" color: #cyan size: 12 font: font("Arial", 12, #bold)
                    at: {15, y_pos};
                y_pos <- y_pos + 6;
                
                // Départ
                draw circle(3) color: #green at: {x_icon, y_pos};
                draw "Point de départ (START)" color: #white size: 11 at: {x_text, y_pos};
                y_pos <- y_pos + 6;
                
                // Destination  
                draw circle(3) color: #red at: {x_icon, y_pos};
                draw "Destination (GOAL)" color: #white size: 11 at: {x_text, y_pos};
                y_pos <- y_pos + 6;
                
                // En exploration
                draw circle(3) color: #yellow at: {x_icon, y_pos};
                draw "Nœud en exploration" color: #white size: 11 at: {x_text, y_pos};
                y_pos <- y_pos + 6;
                
                // Visité
                draw circle(3) color: #lightblue at: {x_icon, y_pos};
                draw "Nœud visité (couleur = niveau)" color: #white size: 11 at: {x_text, y_pos};
                y_pos <- y_pos + 6;
                
                // Non visité
                draw circle(3) color: #blue at: {x_icon, y_pos};
                draw "Nœud non visité" color: #white size: 11 at: {x_text, y_pos};
                y_pos <- y_pos + 6;
                
                // Chemin final
                draw circle(3) color: #purple at: {x_icon, y_pos};
                draw "Chemin optimal final" color: #white size: 11 at: {x_text, y_pos};
                y_pos <- y_pos + 8;
                
                // Section Éléments
                draw "ÉLÉMENTS:" color: #orange size: 12 font: font("Arial", 12, #bold)
                    at: {15, y_pos};
                y_pos <- y_pos + 6;
                
                // Obstacles
                draw rectangle(5, 3) color: #gray at: {x_icon, y_pos};
                draw "Obstacles (bloquent les connexions)" color: #white size: 11 at: {x_text, y_pos};
                y_pos <- y_pos + 6;
                
                // Connexions
                draw line([{x_icon-3, y_pos}, {x_icon+3, y_pos}]) color: #lightblue width: 2;
                draw "Connexions entre nœuds" color: #white size: 11 at: {x_text, y_pos};
                y_pos <- y_pos + 6;
                
                // Zone d'exploration
                draw polygon([{x_icon-2, y_pos-1}, {x_icon+2, y_pos-1}, {x_icon+2, y_pos+1}, {x_icon-2, y_pos+1}]) 
                    color: rgb(0, 100, 200, 100);
                draw "Zone d'exploration (enveloppe convexe)" color: #white size: 11 at: {x_text, y_pos};
                y_pos <- y_pos + 8;
                
                // Section Informations
                draw "INFORMATIONS:" color: #yellow size: 12 font: font("Arial", 12, #bold)
                    at: {15, y_pos};
                y_pos <- y_pos + 6;
                
                draw "• Les nombres sur les nœuds indiquent la distance" color: #white size: 10 at: {18, y_pos};
                y_pos <- y_pos + 4;
                draw "• La couleur des nœuds visités varie selon le niveau BFS" color: #white size: 10 at: {18, y_pos};
                y_pos <- y_pos + 4;
                draw "• L'effet de vague montre la propagation de l'exploration" color: #white size: 10 at: {18, y_pos};
            }
        }
        
        // ===== DISPLAY STATISTIQUES SÉPARÉ =====
        display "📊 Statistiques" type: 2d background: rgb(25, 35, 50) refresh: every(1#cycle) 
                 synchronized: false {
            graphics "statistiques_detaillees" {
                // Titre et état
                draw "STATISTIQUES BFS" color: #white size: 16 font: font("Arial", 16, #bold)
                    at: {50, 8};
                
                string etat <- recherche_terminee ? "TERMINÉ" : "EN COURS";
                rgb couleur_etat <- recherche_terminee ? #lime : #orange;
                draw "État: " + etat color: couleur_etat size: 14 font: font("Arial", 14, #bold)
                    at: {50, 16};
                
                // Ligne de séparation
                draw line([{10, 20}, {90, 20}]) color: rgb(255, 255, 255, 150) width: 2;
                
                float y_stat <- 26;
                float x_label <- 15;
                float x_value <- 60;
                
                // Progression
                draw "PROGRESSION:" color: #cyan size: 12 font: font("Arial", 12, #bold)
                    at: {x_label, y_stat};
                y_stat <- y_stat + 6;
                
                draw "Étape actuelle:" color: #white size: 11 at: {x_label + 5, y_stat};
                draw string(etape_actuelle) color: #yellow size: 11 font: font("Arial", 11, #bold) 
                    at: {x_value, y_stat};
                y_stat <- y_stat + 4;
                
                draw "Nœuds visités:" color: #white size: 11 at: {x_label + 5, y_stat};
                draw string(length(noeuds_visites)) + "/" + string(nb_points) 
                    color: #lightgreen size: 11 font: font("Arial", 11, #bold) 
                    at: {x_value, y_stat};
                y_stat <- y_stat + 4;
                
                draw "File d'attente:" color: #white size: 11 at: {x_label + 5, y_stat};
                draw string(length(file_attente)) color: #orange size: 11 font: font("Arial", 11, #bold) 
                    at: {x_value, y_stat};
                y_stat <- y_stat + 4;
                
                float pourcentage <- nb_points > 0 ? (length(noeuds_visites) / nb_points) * 100 : 0;
                draw "Progression:" color: #white size: 11 at: {x_label + 5, y_stat};
                draw string(pourcentage with_precision 1) + "%" 
                    color: #magenta size: 11 font: font("Arial", 11, #bold) 
                    at: {x_value, y_stat};
                y_stat <- y_stat + 8;
                
                // Résultats
                draw "RÉSULTATS:" color: #lime size: 12 font: font("Arial", 12, #bold)
                    at: {x_label, y_stat};
                y_stat <- y_stat + 6;
                
                if (!empty(chemin_final)) {
                    draw "Chemin trouvé:" color: #white size: 11 at: {x_label + 5, y_stat};
                    draw string(length(chemin_final) - 1) + " nœuds" 
                        color: #purple size: 11 font: font("Arial", 11, #bold) 
                        at: {x_value, y_stat};
                    y_stat <- y_stat + 4;
                    
                    float efficacite <- length(noeuds_visites) > 0 ? 
                        (length(chemin_final) / length(noeuds_visites)) : 0;
                    draw "Efficacité:" color: #white size: 11 at: {x_label + 5, y_stat};
                    draw string(efficacite with_precision 3) 
                        color: #cyan size: 11 font: font("Arial", 11, #bold) 
                        at: {x_value, y_stat};
                    y_stat <- y_stat + 4;
                } else {
                    draw "Chemin:" color: #white size: 11 at: {x_label + 5, y_stat};
                    draw recherche_terminee ? "INTROUVABLE" : "Recherche..."
                        color: recherche_terminee ? #red : #yellow 
                        size: 11 font: font("Arial", 11, #bold) 
                        at: {x_value, y_stat};
                    y_stat <- y_stat + 4;
                }
                
                if (point_depart != nil and point_destination != nil) {
                    draw "Distance euclidienne:" color: #white size: 11 at: {x_label + 5, y_stat};
                    draw string(point_depart distance_to point_destination with_precision 2) 
                        color: #lightblue size: 11 font: font("Arial", 11, #bold) 
                        at: {x_value, y_stat};
                    y_stat <- y_stat + 8;
                }
                
                // Configuration
                draw "CONFIGURATION:" color: #orange size: 12 font: font("Arial", 12, #bold)
                    at: {x_label, y_stat};
                y_stat <- y_stat + 6;
                
                draw "Connexions totales:" color: #white size: 11 at: {x_label + 5, y_stat};
                draw string(int(nb_connexions_totales / 2)) 
                    color: #lightblue size: 11 font: font("Arial", 11, #bold) 
                    at: {x_value, y_stat};
                y_stat <- y_stat + 4;
                
                draw "Obstacles:" color: #white size: 11 at: {x_label + 5, y_stat};
                draw string(nb_obstacles) 
                    color: #gray size: 11 font: font("Arial", 11, #bold) 
                    at: {x_value, y_stat};
                y_stat <- y_stat + 4;
                
                draw "Voisins max/nœud:" color: #white size: 11 at: {x_label + 5, y_stat};
                draw string(nb_voisins) 
                    color: #white size: 11 font: font("Arial", 11, #bold) 
                    at: {x_value, y_stat};
                y_stat <- y_stat + 8;
                
                // Performances
                if (recherche_terminee) {
                    draw "PERFORMANCES:" color: #pink size: 12 font: font("Arial", 12, #bold)
                        at: {x_label, y_stat};
                    y_stat <- y_stat + 6;
                    
                    float duree <- temps_fin - temps_debut;
                    draw "Temps d'exécution:" color: #white size: 11 at: {x_label + 5, y_stat};
                    draw string(duree with_precision 3) + "s" 
                        color: #yellow size: 11 font: font("Arial", 11, #bold) 
                        at: {x_value, y_stat};
                    y_stat <- y_stat + 4;
                    
                    float vitesse <- etape_actuelle > 0 ? etape_actuelle / duree : 0;
                    draw "Vitesse:" color: #white size: 11 at: {x_label + 5, y_stat};
                    draw string(vitesse with_precision 1) + " étapes/s" 
                        color: #lime size: 11 font: font("Arial", 11, #bold) 
                        at: {x_value, y_stat};
                }
            }
        }
        
        // ===== DISPLAY GRAPHIQUE DE PROGRESSION =====
        display "📈 Évolution" type: 2d background: #white refresh: every(2#cycles) 
                 synchronized: false {
            chart "Évolution de la recherche BFS" type: series size: {1.0, 0.6} position: {0, 0} {
                data "Nœuds visités" value: length(noeuds_visites) color: #blue thickness: 2;
                data "File d'attente" value: length(file_attente) color: #orange thickness: 2;
                data "Étape actuelle" value: etape_actuelle color: #green thickness: 2;
            }
            
            chart "Répartition des nœuds" type: pie size: {1.0, 0.4} position: {0, 0.6} {
                data "Visités" value: length(noeuds_visites) color: #lightblue;
                data "Non visités" value: nb_points - length(noeuds_visites) color: #lightgray;
                data "En attente" value: length(file_attente) color: #orange;
            }
        }
        
		        // ===== DISPLAY MINIMAL POUR VUE D'ENSEMBLE (CORRIGÉ) =====
		display "🎯 Vue d'ensemble" type: 2d background: rgb(30, 30, 30) refresh: every(3#cycles) 
		         synchronized: false {
		    graphics "resume" {
		        // Titre
		        draw "RÉSUMÉ BFS" color: #white size: 20 font: font("Arial", 20, #bold)
		            at: {50, 10};
		        
		        // État principal - CORRECTIONS ICI
		        if (recherche_terminee) {
		            if (!empty(chemin_final)) {
		                draw "✅ SUCCÈS" color: #lime size: 24 font: font("Arial", 24, #bold)
		                    at: {50, 30};
		                draw "Chemin de " + string(length(chemin_final) - 1) + " nœuds trouvé" 
		                    color: #lightgreen size: 16 at: {50, 40};
		                draw "en " + string(etape_actuelle) + " étapes" 
		                    color: #cyan size: 14 at: {50, 48};
		            } else {
		                draw "❌ ÉCHEC" color: #red size: 24 font: font("Arial", 24, #bold)
		                    at: {50, 30};
		                draw "Aucun chemin possible" 
		                    color: #orange size: 16 at: {50, 40};
		                draw string(length(noeuds_visites)) + " nœuds explorés" 
		                    color: #yellow size: 14 at: {50, 48};
		            }
		        } else {
		            draw "🔄 EN COURS" color: #yellow size: 24 font: font("Arial", 24, #bold)
		                at: {50, 30};
		            draw "Étape " + string(etape_actuelle) 
		                color: #orange size: 16 at: {50, 40};
		            draw string(length(noeuds_visites)) + "/" + string(nb_points) + " nœuds visités" 
		                color: #cyan size: 14 at: {50, 48};
		        }
		        
		        // Barre de progression
		        float prog_width <- 60.0;
		        float prog_height <- 4.0;
		        float prog_x <- 50 - prog_width/2;
		        float prog_y <- 60;
		        
		        // Fond de la barre
		        draw rectangle(prog_width, prog_height) color: #gray 
		            at: {50, prog_y};
		        
		        // Progression
		        float progression <- nb_points > 0 ? (length(noeuds_visites) / nb_points) : 0;
		        float prog_fill <- prog_width * progression;
		        if (prog_fill > 0) {
		            draw rectangle(prog_fill, prog_height) color: #lime 
		                at: {prog_x + prog_fill/2, prog_y};
		        }
		        
		        // Pourcentage - CORRECTION ICI AUSSI
		        draw string(progression * 100 with_precision 1) + "%" 
		            color: #white size: 12 font: font("Arial", 12, #bold)
		            at: {50, prog_y + 8};
		        
		        // Informations complémentaires - CORRECTIONS ICI
		        draw "Configuration: " + string(nb_points) + " nœuds, " + string(nb_voisins) + " voisins, " + string(nb_obstacles) + " obstacles" 
		            color: #lightgray size: 10 at: {50, 75};
		        
		        if (point_depart != nil and point_destination != nil) {
		            draw "Distance euclidienne: " + string(point_depart distance_to point_destination with_precision 2) 
		                color: #lightblue size: 10 at: {50, 82};
		        }
		        
		        // Contrôles suggérés
		        draw "💡 Conseils: Utilisez les displays séparés pour plus de détails" 
		            color: #yellow size: 9 at: {50, 92};
		    }
		}
		
		// ===== CORRECTIONS SUPPLÉMENTAIRES DANS LES MONITEURS =====
		monitor "🎯 État" value: recherche_terminee ? "TERMINÉ" : "EN COURS" 
		        color: recherche_terminee ? #green : #orange;
		monitor "📊 Progression" value: string(length(noeuds_visites)) + "/" + string(nb_points) + 
		        " (" + string((length(noeuds_visites) / nb_points) * 100 with_precision 1) + "%)";
		monitor "⏳ File d'attente" value: string(length(file_attente));
		monitor "🔢 Étape" value: string(etape_actuelle);
		monitor "📏 Chemin" value: empty(chemin_final) ? "N/A" : string(length(chemin_final) - 1);
		monitor "⚡ Efficacité" value: empty(chemin_final) or length(noeuds_visites) = 0 ? "N/A" : 
		        string((length(chemin_final) / length(noeuds_visites)) with_precision 3);
    }
}
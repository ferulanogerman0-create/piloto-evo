# piloto-evo

Evolution API (develop) con el parche de Baileys que arregla la vinculación de
dispositivos nuevos (evolution-api PR #2727, fijado al commit dffeac4).

GitHub Actions compila la imagen y la publica en `ghcr.io/<owner>/piloto-evo`.
EasyPanel (`fervor/piloto-evo`) la usa como fuente de imagen: no se compila en
el VPS (2 núcleos, compilar ahí tumba los servicios).

Sacar todo esto cuando Evolution publique una versión oficial con el arreglo.

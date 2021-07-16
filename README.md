# OVFabmanager

OVFabmanager est la solution développée pour la gestion de l'atelier numérique Orles Valley.
Cette solution est pourvue des fonctionnalités suivantes :

* Réservation de machines ou d’espaces par le client à une date et un créneau horaire définis,

* Identification et contrôle automatique de l’accès du client à tel ou tel espace en fonction de l’abonnement souscrit,

* Identification et contrôle automatique de l’utilisation d’une machine par le client en fonction de l’abonnement souscrit et du crédit dont il dispose,

* Contrôle par le manager des données relatives aux clients (nom, prénom, abonnement souscrit, et crédit dont il dispose),

* Contrôle par le manager des accès aux locaux et utilisation des machines par tel ou tel client,

* Gestion par le client de son abonnement avec possibilité de le modifier en cas de besoin,

* Gestion par le client de son crédit avec possibilité de le recharger en cas de besoin,

* Gestion des stocks et de l'inventaire du fablab par le fabmanager,

* Gestion des paniers des clients par le fabmanager.

Il s'agit d'un fork de la solution FabManager : le dêpot github est [ici](https://github.com/sleede/fab-manager) et le site officiel est [ici](https://www.fab-manager.com/).

##### Table des matières

1. [Installer OVFabmanager en version de développement sur une machine virtuelle](#installer_OVFabmanager_en_version_de_developpement_sur_une_machine_virtuelle)

2. [Installer OVFabmanager en version de développement sur une machine quelconque](#installer_OVFabmanager_en_version_de_developpement_sur_une_machine_quelconque)

3. [Installer OVFabmanager en production avec Docker](#installer_OVFabmanager_en_production_avec_docker)

4. [Accéder à la base de données dans la version de développement d'OVFabmanager](#acceder_a_la_base_de_donnees_dans_la_version_de_developpement)

5. [Modifier la structure de la base de données](#modifier_la_structure_de_la_base_de_donnees)

6. [Pour aller plus loin](#pour_aller_plus_loin)

<a name="installer_OVFabmanager_en_version_de_developpement_sur_une_machine_virtuelle"></a>
## Installer OVFabmanager en version de développement sur une machine virtuelle

Cette section s'adresse à ceux qui veulent installer une version de développement ou de test d'OVFabmanager dans une machine virtuelle avec la plupart des dépendances logicielles installées automatiquement et en évitant d'en installer beaucoup d'autres directement sur l'ordinateur hôte.

**Note:** Les scripts de configuration configurent les dépendances du logiciel pour qu'elles fonctionnent bien entre elles alors qu'elles se trouvent dans le même environnement virtuel, mais ladite configuration n'est pas optimisée pour un environnement de production.
**Note 2:** Les performances de l'application sous la machine virtuelle dépendent des ressources que l'hôte peut fournir mais seront généralement beaucoup plus lentes qu'un environnement de production.

Tout d'abord si ce n'est pas déjà fait, installez <a href="https://www.vagrantup.com/downloads.html">Vagrant</a> et <a href="https://www.virtualbox.org/wiki/Downloads">Virtual Box</a>.

Ensuite, clonez le projet depuis GitLab à l'aide de la commande suivante:

```bash
git clone https://gitlab.imerir.com/orles-valley/ovfabmanager
```
Puis placez-vous dans le répertoire du projet cloné à l'aide de la commande suivante:

```bash
cd ovfabmanager
```

Une fois dans celui-ci, lancez la commande suivante:

```bash
vagrant up
```

Cette commande va créer et builder la machine virtuelle sur laquelle fab-manager sera installé avec toutes ses dépendances logicielles puis configurées.
Une fois fait, lancez la commande suivante:

```bash
vagrant reload
```

Cette commande vous permet de relancer la machine après installation et build.

Maintenant, connectez-vous à la nouvelle machine à l'aide de la commande suivante:

```bash
vagrant ssh
```

Ensuite allez dans le répertoire du projet (si vous n'y êtes pas) et installez les dépendances Gemfile: 

```bash
bundle install

yarn install
```

Maintenant, configurez les bases de données (Notez que vous devez fournir les informations d'identification d'administrateur souhaitées et que cet ensemble spécifique de commandes doit être utilisé pour configurer la base de données car certaines instructions SQL brutes sont incluses dans les migrations. La longueur minimale du mot de passe est de 8 caractères):

```bash
rake db:create
rake db:migrate
# Veillez à ne pas utiliser les valeurs par défaut ci-dessous en production
ADMIN_EMAIL='admin@email' ADMIN_PASSWORD='adminpass' rake db:seed
rake fablab:es:build_stats
# Pour les tests
RAILS_ENV=test rake db:create
RAILS_ENV=test rake db:migrate
```

Pour finir, démarrez l'application grâce à la commande suivante:

```bash
foreman s -p 3000
```

Pour vous connecter à l'application, rendez-vous à cette adresse `localhost:3000`.
Pour consulter les emails envoyés par l'application, rendez-vous à cette adresse `localhost:1080`.

<a name="installer_OVFabmanager_en_version_de_developpement_sur_une_machine_quelconque"></a>
## Installer OVFabmanager en version de développement sur une machine quelconque

Tout d'abord, installez sur votre machine l'utilitaire RVM. Pour plus de détails, nous vous renvoyons à la documentation officielle <a href="http://rvm.io/rvm/install">ici</a>.

Ensuite, installez la version de ruby spécifiée <a href="https://gitlab.imerir.com/orles-valley/ovfabmanager/blob/master/.ruby-version">ici</a>

Puis installez sur votre machine l'utilitaire NVM. Pour plus de détails, nous vous renvoyons <a href="https://github.com/nvm-sh/nvm#installation">ici</a>.

Ensuite, installez la version de node.js spécifiée <a href="https://gitlab.imerir.com/orles-valley/ovfabmanager/blob/master/.nvmrc">ici</a>.

Maintenant installez Yarn, le logiciel de gestion de packages front-end. Le processus d'installation diffère selon le système, alors veuillez consulter la documentation officielle <a href="https://yarnpkg.com/en/docs/install#debian-stable">ici</a>.

Puis installez la dernière version de docker. Pour cela, veuillez vous référer à la documentation officielle <a href="https://docs.docker.com/install/">ici</a>.

Maintenant, ajoutez votre utilisateur actuel au groupe docker pour autoriser l'utilisation de docker sans `sudo`.
Pour cela, exécutez les commandes suivantes:

```bash

# ajouter le groupe docker s'il n'existe pas déjà
sudo groupadd docker

# ajouter l'utilisateur actuel au groupe de dockers
sudo usermod -aG docker $(whoami)

# rebooter pour valider les modifications
sudo reboot

```
Puis créez un réseau de dockers pour fab-manager à l'aide de la commande suivante:

```bash
docker network create --subnet=172.18.0.0/16 fabmanager
```
 
Vous devrez peut-être modifier l'adresse réseau si elle est déjà utilisée.

Maintenant clonez le projet depuis GitLab à l'aide de la commande suivante:

```bash
git clone https://gitlab.imerir.com/orles-valley/ovfabmanager
```
Installez maintenant les dépendances logicielles.

Pour cela, installez d'abord <a href="https://github.com/sleede/fab-manager#postgresql">PostgreSQL</a> et <a href="https://github.com/sleede/fab-manager#elasticsearch">ElasticSearch</a> comme spécifié dans leurs documentations respectives.
Puis installez les autres dépendances:

```bash
# Sur Ubuntu 18.04 server, vous devrez peut-être activer le référentiel "universe"
sudo add-apt-repository universe
# Maintenant, installez les référentiels
sudo apt-get install libpq-dev redis-server imagemagick
```
Ensuite initialisez les instances RVM et NVM et vérifiez qu'elles ont été correctement configurées:

```bash
cd fab-manager
rvm current | grep -q `cat .ruby-version`@fab-manager && echo "ok"
# Doit écrire ok dans la console
nvm use
node --version | grep -q `cat .nvmrc` && echo "ok"
# Doit écrire ok dans la console
```

Puis installez bundler dans le gemset RVM courant:

```bash
gem install bundler --version=1.17.3
```
Maintenant installez les gems ruby et les plugins javascript requis:

```bash
bundle install
yarn install
```

Ensuite créez les fichiers de configuration par défaut et **configurez-les !** (pour plus d'informations cliquez <a href="https://github.com/sleede/fab-manager/blob/master/doc/environment.md">ici</a>)

```bash
cp config/database.yml.default config/database.yml
cp config/application.yml.default config/application.yml
vi config/application.yml
# ou utilisez votre éditeur de texte préféré à la place de vi (nano, vim, gedit...)
```

Ensuite compilez les bases de données.

- **ATTENTION**: n'exécutez surtout pas `rake db:setup` au lieu de ces commandes, car cela n'exécutera pas certaines instructions SQL brutes requises.
- **ENCORE ATTENTION**: La longueur de votre mot de passe doit être comprise entre 8 et 128 caractères, sinon `db:seed` sera rejetée. Cela est configuré dans le fichier [config/initializers/devise.rb](config/initializers/devise.rb).

```bash
# pour le dev
rake db:create
rake db:migrate
ADMIN_EMAIL='youradminemail' ADMIN_PASSWORD='youradminpassword' rake db:seed
rake fablab:es:build_stats
# pour les tests
RAILS_ENV=test rake db:create
RAILS_ENV=test rake db:migrate
```

Puis exécutez la commande suivante:

```bash
mkdir -p tmp/pids
```

il permet de créer le dossier pids utilisé par Sidekiq. Si vous souhaitez utiliser un emplacement différent, vous pouvez le configurer dans `config/sidekiq.yml`

Pour terminer, démarrez le serveur web de développement:

```bash
foreman s -p 3000
```

Vous devez maintenant pouvoir accéder à votre instance de développement en local OVFabmanager grâce à cette adresse URL à renseigner dans votre navigateur web:

```bash
http://localhost:3000
```

Vous pouvez maintenant vous connecter en tant qu'administrateur par défaut à l'aide des informations d'identification définies précédemment.

De plus, les notifications par email seront capturées par MailCatcher. 
Pour voir les e-mails envoyés par la plateforme, ouvrez votre navigateur Web à l'adresse URL suivante pour accéder à l'interface MailCatcher: 

```bash
http://localhost:1080
```

<a name="installer_OVFabmanager_en_production_avec_docker"></a>
## Installer OVFabmanager en production avec Docker

# Prérequis

docker et docker-compose sont requis pour l'installation d'OVFabmanager en production.

Vous pouvez vérifier en tapant les commandes suivantes:

```bash
docker --version #Affiche la version de docker installée

docker-compose --version #Affiche la version de docker-compose installée
```

Si ils sont installés, passez à la suite.

Sinon, veuillez consulter la procédure d'installation de docker <a href="https://docs.docker.com/install/linux/docker-ce/ubuntu/">ici</a> et de docker-compose <a href="https://docs.docker.com/compose/install/">ici</a>.

# Procédure

Tout d'abord, mettez vous en super-utilisateur grâce à la commande suivante:

```bash
sudo su -
```

Ensuite, clonez le dépôt GitLab:

```bash
git clone https://gitlab.imerir.com/orles-valley/ovfabmanager
```

Ensuite, exécutez la commande suivante dans le répertoire où OVFabmanager a été cloné pour préparer le serveur:

```bash
sudo ./ovfabmanager/scripts/prepare-vps.sh
```

Puis, exécutez cette commande dans le répertoire où OVFabmanager a été cloné:

```bash
sudo ./ovfabmanager/docker/setup.sh
```

ou dans le cas où le chemin doit être spécifié:

```
sudo ./ovfabmanager/docker/setup.sh "chemin_specifié"
```

Créez le répertoire config dans le répertoire où OVFabmanager doit être installé (ici /apps/fabmanager):

```bash
mkdir -p /apps/fabmanager/config
```

Ensuite, dans le répertoire config nouvellement créé, copiez les fichiers de configuration et éditez-les:

```bash
cd /apps/fabmanager
cp example/env.example config/env
vi config/env 
# ou l'éditeur de texte de votre choix (nano, vim, gedit...)
```

Maintenant, il est temps de configurer le serveur nginx. Pour cela, lancez les commandes suivantes:

```bash
mkdir -p /apps/fabmanager/config/nginx
# Que vous souhaitiez que fab-manager utilise ou non le cryptage SSL, vous devez copier l'un des fichiers suivants
### Avec SSL ### 
cp example/nginx_with_ssl.conf.example config/nginx/fabmanager.conf
### OU sans SSL ###
cp example/nginx.conf.example config/nginx/fabmanager.conf

vi config/nginx/fabmanager.conf
# ou l'éditeur de texte de votre choix (nano, vim, gedit...)
```

Vous devriez déjà avoir un fichier docker-compose.yml dans votre dossier d'application (ici /apps/fabmanager), sinon veuillez consulter cette page <a href="https://github.com/sleede/fab-manager/tree/master/docker#retrieve-config-files">ici</a>.

Les commandes docker-compose doivent être lancées à partir du dossier d'application (ici /apps/fabmanager).

Exécutez donc cette commande dans le dossier d'application:

```bash
docker-compose pull
```

Exécutez ensuite ces commandes-ci pour créer et configurer la base de données:

```bash
docker-compose run --rm fabmanager bundle exec rake db:create # créez la base de données
docker-compose run --rm fabmanager bundle exec rake db:migrate # exécutez toutes les migrations
# remplacez xxx par votre adresse email et votre mot de passe par défaut
docker-compose run --rm -e ADMIN_EMAIL=xxx -e ADMIN_PASSWORD=xxx fabmanager bundle exec rake db:seed
```

**Petite précision**: lorsque la commande `docker-compose run --rm fabmanager bundle exec rake db:migrate` s'exécute pour la première fois, une erreur se génère disant que la clé de configuration n'a pas été entré dans le fichier config/env.

Cette erreur se génère avec une longue chaine de caractères suivant `secret_config_key=`.

Pour la corriger, il faut copier toute la chaine de caractères qui suit `secret_config_key=` dans le fichier config/env dans le champ SECRET_KEY_BASE.

Réexecutez ensuite la commande.

Ensuite, compilez les assets:

```bash
docker-compose run --rm fabmanager bundle exec rake assets:precompile
```

Puis, préparez ElasticSearch:

```bash
docker-compose run --rm fabmanager bundle exec rake fablab:es:build_stats
```

Pour terminer, exécutez la commande suivante pour supprimer le dépot GitLab dans le répertoire où il a été cloné:

```bash
rm -r ovfabmanager
```

Puis démarrer tous les services à l'aide de cette commande:

```bash
docker-compose up -d
```

Pour vous connecter à l'application, rendez-vous à cette adresse `localhost`.

<a name="acceder_a_la_base_de_donnees_dans_la_version_de_developpement"></a>
## Accéder à la base de données dans la version de développement d'OVFabmanager

Tout d'abord, connectez-vous à la machine virtuelle sur laquelle s'exécute la version de développement d'OVFabmanager si ce n'est pas déjà le cas.

Ensuite, exécutez les commandes suivantes:

```bash
sudo -i -u postgres #Cette commande permet de vous connecter à l'utilisateur postgres

psql #Cette commande vous permet d'accéder à l'interface en mode texte pour PostgreSQL
```

Une fois ces commandes exécutées le prompt de la machine virtuelle est modifié, il passe de `± %` à `postgres=#`.

Pour lister toutes les bases de données enregistrées, tapez la commande `\l`.

Si vous la tapez, vous remarquerez qu'il existe 2 bases de données pour OVFabmanager.

1. fabmanager_development,

2. fabmanager_test.

C'est la base de données `fabmanager_development` qui nous intéresse ici car c'est elle qui est utilisé par la version de développement d'OVFabmanager.

La base de données `fabmanager_test` est  utilisé par la version de test d'OVFabmanager.

Pour vous connecter à une base de données sous PostgreSQL il faut utiliser la commande suivante:

```bash
\c <nom_de_la_base_de_données>
```

Donc tapez `\c fabmanager_development` pour vous connecter à la base `fabmanager_development`.

Pour lister toutes les tables et les séquences appartenant à la base de données auquel on est connectée (ici `fabmanager_development`) tapez la commande suivante `\d`.

Pour afficher la structure d'une table 2 commandes sont possibles:

```bash
\d <nom_de_la_table>
```

ou (pour des résultats plus détaillés)

```bash
\d+ <nom_de_la_table>
```

Pour quitter PostgreSQL tapez la commande suivante `\q`.

<a name="modifier_la_structure_de_la_base_de_donnees"></a>
## Modifier la structure de la base de données

La structure de la base de données est définie par le fichier `schema.rb` situé dans le répertoire `db` et consultable <a href="https://gitlab.imerir.com/orles-valley/ovfabmanager/blob/master/db/schema.rb">ici</a>.

Tout d'abord, connectez-vous à la machine virtuelle sur laquelle s'exécute la version de développement d'OVFabmanager si ce n'est pas déjà le cas.

Ensuite, connectez-vous à PostgreSQL (voir [ici](#acceder_a_la_base_de_donnees_dans_la_version_de_developpement))puis apportez les modifications nécessaires à la structure de la base de données d'OVFabmanager (changement du type de donnée d'une colonne, ajout ou suppression de tables, de colonnes, de clés étrangères....).

Après avoir effectué vos modifications quittez PostgreSQL, puis (toujours dans la machine virtuelle sur laquelle s'exécute la version de développement d'OVFabmanager) tapez la commande suivante:

```bash
rake db:schema:dump
```

Une fois cette commande exécutée avec succès, le fichier `schema.rb` a bel et bien été modifié.

Si vous voulez ajouter vos modifications au projet courant, faites-y un commit sur le dêpot gitlab du projet OVFabmanager.

<a name="pour_aller_plus_loin"></a>
## Pour aller plus loin

Comme dit plus haut, OVFabmanager est un fork de la solution FabManager.

Si vous voulez aller plus loin rendez-vous [ici](https://github.com/sleede/fab-manager).

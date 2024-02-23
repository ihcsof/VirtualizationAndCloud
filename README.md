[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/wVIqdTGN)
# VCC Project 2023-2024

Hello and welcome to the VCC Project 2023-2024 repository.

Support [Giacomo](mailto:giacomo.longo@dibris.unige.it)

Look for **TODO** tags in the repository to find out which tasks are to be performed

## Usage

Use

- `vagrant up` to boot the vagrant VMs
- `vagrant destroy -f` to stop them
- `vagrant ssh VCC-control` to access the shell of the VCC control node
  - You will find the playbook inside of the `/vagrant` directory
- `vagrant ssh VCC-target1` to access the shell of the VCC first node
- `vagrant ssh VCC-target2` to access the shell of the VCC second node

## DNS names

Within the scenario machines, `controlnode.vcc.local`, `target1.vcc.local`, and `target2.vcc.local` resolve to the machines IP addresses.

On `target1` and `target2`, `registry.vcc.local` resolves to `127.0.0.1` (the loopback address).

**Remember that in order to access the project websites from your own browser you need to add host aliases pointed to one of the nodes ON YOUR HOST**
--------------------------------------------------------------------------------------------
# Report on the Virtualization Project \ VCC-FDC
## Foschi, Dellepere, Cattaneo

The virtualization project was an engaging experience that allowed us to explore and apply various fundamental concepts and tools such as Vagrant, Ansible, Docker, and Swarm. Throughout the project implementation, we tackled a series of tasks that contributed to developing a practical and in-depth understanding of these technologies.

### 20/12/2023 (night): Vagrant hell
The first hours were devoted to some vagrant bug-solving. These were our notes:
- Need to run `vagrant plugin install vagrant-sshfs` before `vagrant up`
- Remember to change the base address in Vagrantfile according to NAT config in VMware
- Problems in Vagrantfile: “The SSH connection was unexpectedly closed by the remote end. This usually indicates that SSH within the guest machine was unable to properly start up. Please boot the VM in GUI mode to check whether it is booting properly”. 
  - SOLUTION: `DEFAULT_PROVIDER = 'vmware'` `instead of DEFAULT_PROVIDER = 'libvirt'` in Vagrantfile 
  - WHY: There are OR's so in certain points it takes libvirt config anyway
- VM too heavy 
  - SOLUTION: I had to decrease manually the RAM allocated to each VM
- INTRUDER ALARM: A random girl entered our repo, kicking out Gabriele: that was funny
- Kevin’s Vagrant-box problem 
  - SOLUTION: ???

### 20/12/2023: Docker, Swarm and NFS Tasks (1-8):
The initial eight tasks related to Docker, Swarm, and NFS were relatively straightforward, thanks to the familiarity gained during the course's lab sessions. Our approach involved carefully understanding the available options, commenting on them, and using only those necessary for the required implementation. We then focused on the scalable version of Task 5, implementing a loop to optimize the process. This was all made in the first commit.

### 21/12/2023 (night): Registry Task (9-13):
The subsequent steps, from 9 to 13, presented some challenges, especially with Task 13 concerning port management and login.
  - SOLUTION for these problems: found on 23/12/2023.
The permissions assignment in TASK 9, initially configured as 0600, was then changed in 0400 using more accurate information from the documentation: as owners we only need to read the key (not also to write it). It's an Ansible responsibility to handle it with privilege escalation.
This was all made in the second commit, except for mistakes in Task 13.
- Kevin can't still run the Vagrantfile due to the unsolved bug

### 21/12/2023: Database Tasks (14-16) and Traefic Tasks (17-23):
The phases related to databases (Tasks 14-16) posed more significant challenges, because it was the first section with mixed approaches to look for. It was initially tough to gain confidence with the project structure and dependencies, but with that database tasks we finally managed to overcome the lack of confidence and start being more proficient. 
  - SOLUTION: found on 23/12/2023.
Said this, we encountered fewer difficulties in implementing the tasks related to Traefic (Tasks 17-23). Traefic tasks were completed in the third commit, where we also started to work onto database tasks. However, we didn’t manage to finish them in this third push.
- Kevin can't still run the Vagrantfile due to the unsolved bug
  
### 22/12/2023: Christmas party prevented us from working on VCC, but our minds were there while seeing Verri winning the best-prof awards.
SIDE NOTE: From this time I'll just wrap everything day-by-day, IDK why I thought it could be useful to have the day-night separation, apart from my love for the night :)

### 23/12/2023: Debugging and improvements of previous done tasks
On this day we stayed (a huge amount of time) solving previously encountered problems:
- **Task 13 failing**:
  - We had to add Create certificate signing request (CSR)
    - (this in particular took us like half a day lol)
- **General problems with Database task**:
  - We all had different methods for this: a merge and a discussion solved everything. The main problems were:
    1. where are the entrypoints?
    2. sql syntax sugar <-- this prevented our compose to create database properly for kinda long time (when we saw "forgejo" in the db_list a giant SIUM arised)
    3. correlation between .sql files and compose.yml
  - We also spent time understanding every line and why it works.
**Then, here are some other key-points that we encountered in this 10hrs vcc-marathon**
- Also, we discovered a new bug (ModuleNotFoundError: No module named 'passlib') when changing TASK 10 from a shell command to leveraging the community.general.htpasswd module. We stayed a couple of hours hanging around with pip3 and dependencies until we found that the right way was installing passlib with apt (we needed the fix the dependency at system-level, not only at python level) and using Bcrypt as hash_scheme. 
  - SOLUTION: "python3-passlib" & "crypt_scheme: bcrypt"
- Another lack was the addition of `tls: yes` in the Run Registry
- We understood that traefik_cert_init serves as entrypoint for enabling SAN extension (for multiple DNS names) and for init the certificate. It was kinda sus at the beginning
- A lot of times we waited minutes to then discover that ansible wanted a dict and not a list (yes, at the beginning we put dashes where they weren't needed... and actually even viceversa)
- Discovering that we can tag tasks was like a text message from the girl you like (I'm Lorenzo, I'll take my responsiiblity for bad memes in this section)
- A big problem was an error in the traefik logs (`docker logs <id>`) that wanted a .pem certificate instead of a .cert one: we had to change the traefik_init entrypoint accordingly
- In that same file, we had a "-addext command not found" error for half an hour due to a comment placed right after a backslash for going newline. That's a meme itself
- Always in that same file, we added a (checked) mkdir for /etc/ssl/traefik in order to create the proper directory for placing the newly created certificates
- Gabriele discovered only after straight 12 hours of work the name of this project
- Useful: for testing purposes we put "any" instead of "on_failure" as a condition for the restart of services
- We use traefik_public as network instead of host, because we need an overlay network (load balancer decides wether to deploy a service in target1 or target2)
- Kevin can't still run the Vagrantfile due to the unsolved bug
NOTE (basics for testing psql): `docker exec -it <id> /bin/bash` --> `psql -U postgres` --> `\l` --> `\q`

### 24/12/2023: Christmas' Eve magic a.k.a Keycloak tasks
- Finally we are all three members together, and (un)funny thing that was the most unproductive day ever because we had so many unknown problems
- we select edge as proxy type because we want clients to communicate with Keycloak with HTTP and then leveraging HTTPS (over TLS) secure network for the internals
- As we found on forums: "Am I the only one that thinks that trying to start Keycloak from just the image is like playing musical chairs with parameters?"
- At least we learned today how to properly debug containers
- Keycloak db failure problem:
    - SOLUTION: we indented labels out of deploy, but doing so we targeted compose and not swarm. When we discovered we wanted to burn our pc's but hey, we learned something. The problem is... another problem arised:
    - Keykcloak db lock problem:
        - SOLUTION: We had to remove transactions from our sql scripts but hey, then another problem arised:
        - Keycloak db user problem:
            - SOLUTION: We had to change the way we created db & user, also changing the order (before user, than db). The problem is... another problem arised!
            - No I was joking that was luckily the last one for today! (Well, it's 1:50 so it's tomorrow, and I've just realized it's actually Christmas so Happy Holidays I guess)
- Kevin tried with Virtualbox, but he can't still run the Vagrantfile due to the unsolved bug
- Keycloak was not showing up into the host browser at auth.vcc.local :(
    - SOLUTION: not found for a long time, see next day!

### 25/12/2023: Christmas' debugging, ho-ho-ho
- **Renaming and Refactoring**
  - Updated .sql files for Grafana and Forgejo
  - Changed traefik_public to overlay_net (semantically the network connecting auth to the database, bypassing traefik)
  - Explicitly using database.vcc.local in the KC_DB_URL denotes usage of the overlay network (as it's the alias defined in that network by the database)
- **Task Modification**
  - In TASK 6, changed enabling of the NFS server from "name: ssh" to "nfs-kernel-server".
- **Useful Commands**
  - `docker exec -it <id> /bin/bash` (or `sh` for Alpine debugging)
    - For PostgreSQL: `psql -U <user> -d <database>` once inside
  - `docker inspect <name>`
  - `docker logs <id> --follow`
  - `docker ps -a`
  - `docker network ls`
  - `docker node ls`
  - `docker service ls`
  - `docker info`
- **Finally we solved Keycloak not showing up at auth.vcc.local in the host**
  - We learned how to read logs properly, and the solution was:
    - SOLUTION: `traefik.http.services.auth.loadbalancer.server.port=8080`
  - After that we performed tasks from 30 to 34, without encountering problems
- **IT'S FORGEJO TIME!**
  - We discovered by brute-forcing `apt-get`, `apt` and then `apk get` that forgejo is an alpine distribution. We also discovered that it's a super-young self-hosted lightweight software forge!
  - We started with building the entrypoint.sh, that Kevin started to build by mistake at the very beginning of the project. However, we were tired and many problems arised with dependencies in the Dockerfile.

### 26/12/2023: Time to delve into Forgejo
- Initially we thought about building FROM alpine to install the dependicies, to then COPY them into the Forgejo image. After some time hanging around with it (we couldn't find the right netcat in alpine, and also the proper way of installing `ca-certificates` to then use `update ca-certificates` command). Finally, we managed to deploy Forgejo with all the right dependencies inside it.
- Once deployed nothing was working, and we then realized that the problem was due to forgejo not waiting for postgres. After some debugging we discovered some inaccuracies in the entrypoint.sh that prevented the proper setup.
  - SIDE NOTE: Testing that was a pain, because postgres is so slow that everytime we could just wait to have a family, have children and see them starting their own VCC project.

### 27/12/2023: Overwelmed by Oauth, We moved to Grafana
- Forgejo was ready to work, but we needed to fix curl not retrieving data in the entrypoint.sh (in order to make https services reachable by all the nodes)
    - FIRST SOLUTION (not choose): leveraging extra_hosts in the Forgejo Compose, but this would force us to hard-code traefik ip's (to let redirection to happen)
    - OUR SOLUTION: putting the right hosts (*.vcc.local) in the host file, leveraging ansible's lineinfile (with a regex) and mounting that /etc/hosts volume in the container where is needed (up to now: keycloak-users, forgejo and grafana in the near future). 
      - We have to point out that this still not works in the N manager scaling scenario, but also Traefik itself is replicated ONE time for the ONE manager, so at the end we chose to leave this solution specifying that we're aware.
      - Moreover, this solution is obviously applied also for Grafana (mon.vcc.local)
- The last "not Oauth related" Forgejo bug was solved specifying the WORKING_DIR for Forgejo
- After trying to work with Oauth + Forgejo we firstly decided to implement Grafana tasks to change our focus for a bit.
  - At the first glance we couldn't manage to start the container, but thanks to `journalctl -u docker.service` we discovered where was the problem
      - SOLUTION: a volume path was wrong, but thanks to this we discovered the usefulness of that command for inspecting tha lifecycle of containers!
  - Then, a lot of problems arised because relevant exported ENV_VARS and labels were missing. We did some research on this and after some times we managed to understand what was needed

### 28/12/2023: Grafana debugging and (hopefully) Oauth
- The last two Grafana bugs, at this point, were:
    - `Failed to open temporary file /etc/ssl/certs/bundleXXXXXX for ca bundle` due to the change of USER before `update ca-certificates`command
      - SOLUTION: giving up to leaving `user: root`, but at least we discovered things on how permissions are handled in that kind of stuff)
    - `GF_PATHS_DATA='/var/lib/grafana' is not writable` due to volume mounting
      - SOLUTION: actually the same of before (We spent so much time on this because I thought that the `user: root` was a "# lol" for it being a really bad solution... lol)
GRAFANA IS ON! But that means that we have to move our lazy a*s onto Oauth's hell:
- **Oauth's hell**:
  - At the current state we don't have full understanding on how to solve Oauth problems. Clicking on SSO button on Forgejo gives no result: actually a 303 response and no logs at all. With Grafana is a bit better, because we obtained a client non recognized error in both GUI and Grafana logs (together with error 303 in network inspector).
  I'll leave this README part with a quote: “Without pain, without sacrifice, we would have nothing” – Fight Club.

### 29/12/2023: Third day of having Oauth in the title, this is starting to become sus...
**But first..**
- Overcomed the impostor-syndrome we're ready to start killing that Oauth monster. But before doing that we initiated Prometheus to start our day with something concrete :)
The only "real" problem that we encountered with deploying it was the docker daemon not running when prometheus.yml was called. The solution was really simple:
  - SOLUTION: adding `- /var/run/docker.sock:/var/run/docker.sock:ro` in the volumes.
**The last Oauth's problems**
- After so much time spent in doing basically nothing but waiting for ansible and services, we discovered the solutions for both Forgejo and Grafana not logging with SSO:
  - SOLUTION for Grafana: the root url was missing in the realm, breaking the redirection with Traefik. Also, in the entrypoint it has to be with tls: `export GF_SERVER_ROOT_URL=https://mon.vcc.local`
  - SOUTION for Forgejo: the --name forgejo option at the end of entrypoint.sh calls was missing
- Now, was only missing the problem of re-generating secrets (if Keycloak fails while either Forgejo or Grafana are still online, when it'll eventually recover it will re-change the secret (changing the 10 "*") and the services will consequently fail). After some time we found the solution:
  - SOLUTION:
**Back to Prometheus! (purple mess)**
- We left back the purple task for the Oauth reverse proxy (prometheus is for now accessible by everyone without authentication, we need to put a middleware). We spent a bit of time trying to understand what exactly we had to do, but then we managed to deploy the proxy.
- We created, for waiting for the authentication and setting the client_secret:
  - Dockerfile for custom image.
  - entrypoint.sh for custom entrypoint for that image.
- We also updated the realm to include a prometheus client (we will be able to do SSO also from it)
- There were some problems that we addressed:
  - `OAUTH2_PROXY_EMAIL_DOMAIN(S)=*`: the final "s" is ambigous into the docs
    - SOLUTION: we found a thread talking about this exact issue. The right version, at the end, was WITH the "s"!
    - MEME: we then shifted to the ENVIROMENT VARS so this problem can be forgotten
  - bind on 0.0.0.0 failing
    - SOLUTION: adding `user : root`
  - Oauth Proxy was trying his best to directly use https, bypassing Traefik!
    - SOLUTION: adding other missing variables, like upstream and callback urls, oidc-issuer-url and others (and others (and others(and others... nothing properly documented in the official docs))).
**TASKS 54-57 (Loki, Promtail) + Fluent-bit** (because today is grinding day)
- Customizing the little details on these three services was easy (only two problems was encountered). The main task was actually understanding _which is the purpose of each service in our scenario_.
  - The first problem encountered was in Loki, because it uses by default UID/GID = 10001 that lacks of mounting permissions. We didn't want to just leverage user : root (it worked), so we spent a bit of time on trying to mount with the right directories in order to have the "right rights" :)
  - (_The second one was in Promtail: it was completely failing during the deployment of the Docker Stack! Then I understood after 20 minutes that the image was missing. Then I saw the clock and it was 4am_)

### 30/12/2023: THE BEGINNING OF THE END
- a.k.a _de beninging of de endin_
- At first we removed our beloved _alpine companion debugging container_
- **Metrics**
- It's time to work with metrics, understanding which labels (like - "prometheus-job") and parameters are needed for each service that we need/want to scrape! We'll list some key-points of the most challenging parts:
  - Ensuring prometheus scrapes only from the overlay_network thanks to a new added source_label into the prometheus.yml
  - Keycloak exports all metrics on 8080, lol
    - Grafana and Forgejo also exports all metrics on 3000
      - SOLUTION: found on 01/01/24, with the not conditions (while registry is not accessible by Traefik)
  - Understanding how Promtail, Fluent-bit and Loki interacts, at which ports and with their own configs
  - Taking Fluent-bit metrics: .metric* endpoint was kinda sus & we discovered that he listen to 2021 port only because we read the logs
  - Remember: Grafana provisioning is enabled by simply mounting where it takes it by default!
  - We had some hard time in understanding how to ensure that logs could be attributed to a specific node. In task 66 it was in and/or with "specific service", so we understood that we had to leverage source labels in promptail as did for the "specific service" in the promptail.yml task):
    - SOLUTION: leveraging `['__meta_docker_container_label_com_docker_swarm_node_id']` source label in promptail.yml (he's the one who has to scrape also from node_name accordingly).
  - Doing, in general, this part's purple tasks was kinda challenging, but the hardest was probably accessing metrics from "node_name" in order to have the registry metrics (accordingly to purple task 12):
    - SOLUTION: adding dockerswarm_sd_configs at the end of prometheus.yml, with a port:5051 replacement (the one that we opened in task 12 as DEBUG PORT for metrics)
- **Cleaning the ansible and preparing the vault**
  - We cleaned some comments, unused parts and other random stuff. Despite that, running ansible-lint showed us other warnings and formatting mistakes!
  - Also, it was time to set up the vault. In the next day we'll select nice secrets and finalize the vault
  - Finally, we keep forgetting about the existence of _forgejo.ini_ :)
- **Getting hands dirty with Grafana**
  - The title says everything. I'll just add that Gabriele loves Pie Charts.

### 31/12/2023: THE PROGRESSION OF THE END
- Added Grafana db (we forgot it) and tested all the db's using psql and then `\dt`
- We leveraged ansible lint to correct all the errors (apart from the swarm-services dir)
  - Most of the errors were _trailing spaces, meta mistakes, permissions, names, formatting and rules_
- Then society prevented us to properly start Grafana's dashboards

### FROM 01/01/2024 TILL THE END OF VCC PROJECT!
- _From now on I won't separate specific days, because grinding is finished and now it's the time for a more relaxed and cautious polishing._
- In the **first day of 2024** we firstly got aware that our group's name choice implicitly posed a naming convention to most of other groups that consequently chose to follow it. The funniest part is that FDC in our minds doesn't stand for FoschiDellepereCattaneo.
  - Then, we finally created a first raw version of dashboards, trying to be curious and exploring what Grafana had to offer.
    - We spent some time in trying to be confident with its dashboard: surely rich but kinda characterized by an high learning curve at the very beginning.
  - Finally (but kinda most importantly) we solved some bothersome problems:
    - Exposed metrics (bug found on 30/12, solved now leveraging compose rules like `!(PathPrefix(/metrics))`.
    - Giving a reason for existing to vcc-admin role, creating exam-admin user in the entrypoint and allowing him (and only him) to access Prometheus.
      - Keycloak sends "unknown errors" to basically everything except "user not found" and "unauthorized", so this made hard doing this part.
- In the **second AND third day of 2023** we got stuck into one of the biggest bugs of all the project: **Accessing with SSO in Grafana as Admin**
  - In order to access with keycloak's SSO in Grafana as Admin users (so being able to actually create dashboards accessing with SSO, even if we could just actually use admin-admin without SSO) we had to retry A LOT of times because the documentation is SO POOR and online there are TONS OF DIFFERENT SOLUTIONS. Also, for every trial we obviously needed to wait at least 5 (if not 10) minutes to all the services to be booted (time that we used to do some other Dashboard work).
    - After having produced 18 different realms (the real number) and scraped every possible website ever existed we obtained the solution, that is (!)basically the combination of the right realm (with the internal creation in Keycloak of the right paths and includes in it) and the right ATTRIBUTE ROLE string syntax. The **SIUM** that I just screamed at 3am waking up all my neighbours will remain in the history.
- In the **fourth, fifth and sixth days of 2023** we: 
  - Thought about our lives
  - Discovered that DC's exam will be in 10th of January (luckily we studied it in December because we already expected us grinding VCC)
  - Completed (again, because it's kinda funny) the three dashboards and provisioned them with the yml file (not before having some last problems with Grafana paths and uid of datasources).
  - Spent some time in choosing memes as passwords in order to create a proper ansible vault
  - Removed newly introuced ansible-lint mistakes
  - The last problem, that took us some time, was a parsing error on log dashboards impacting '|=' expression.
    - SOLUTION: we had uid = "" in the dahsboard json's (mistakenly thinking that Grafana would infer the datasource correctly from the type just right above), but the right approach was adding specific uid's into the datasources files (one for loki and one for prometheus) and then manually specifying them into all the uid's occurencies in the json. Given that this is required only when also scraped Logs from Loki are present in the dashboard (due to Grafana automatically taking Prometheus as datasource by default) we also chose to add specific uid's in the "only-prometheus" dashboard in order to make it scalable.
  - We tried to scale to 3 nodes and it worked!
  - We solved everything in ansible lint (except for missing meta platforms and swarm-services dirname because we thought being not relevant)
  - We screamed SIUM another time: now we only need to check a bunch of stuff and then we'll commit the final sacrifice to the VCC god.
  
### 07/01/2024: The final sacrifice to the VCC god
  - :)

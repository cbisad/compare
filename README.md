Scripts comparing OpenStack packages version as well as docker container version between OpenStack nodes as well as between 2 sites running Red Hat OpenStack.

compare_packages.sh/compare_packages.py

For Bash, Arrays are used to start node IP and role type to be used within loops.
For Python, a dictionnary is used to start node IP and role type to be used within loops.

1) The first step is collecting the node details, this could be changed easily for environments not on OpenStack.
2) The second step is connecting via SSH to each of the node and collecting some information defined in the ssh_commands variable.
3) The third and last step is comparing the datas between each node type.

The script needs to be run from Undercloud and will create its datas into /tmp directory. 

compare_dc.sh

After that, 2 DCs can be compared together (it will be needed to copy the files of the comparison to a single point):
-dc1
-dc2

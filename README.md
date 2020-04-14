Scripts comparing OpenStack packages version as well as docker container version between OpenStack nodes as well as between 2 sites running Red Hat OpenStack.

# 1/compare_packages

* For Bash, Arrays are used to start node IP and role type to be used within loops.
* For Python, a dictionnary is used to start node IP and role type to be used within loops.

1) The first step is collecting the node details, this could be changed easily for environments not on OpenStack.
2) The second step is connecting via SSH to each of the node and collecting some information defined in the ssh_commands variable.
3) The third and last step is comparing the datas between each node type.

The script needs to be run from Undercloud and will create its datas into /tmp directory. 

# 2/compare_dc

After that, 2 DCs can be compared together (it will be needed to copy the files of the comparison to a single point):
* dc1
* dc2

# 3/File structure:
```
(undercloud) [stack@undercloud dc1]$ cat Director-127.0.0.1
ansible-2.6.19-1.el7ae.noarch
ansible-pacemaker-1.0.4-0.20180220234310.0e4d7c0.el7ost.noarch
...
zip-3.0-11.el7.x86_64
zlib-1.2.7-18.el7.x86_64
```
```
(undercloud) [stack@undercloud dc1]$ cat Controller-192.168.11.10
192.168.11.5:8787/rhosp13/openstack-neutron-dhcp-agent:13.0-101
registry.access.redhat.com/rhosp13/openstack-cinder-backup:pcmklatest
...
pacemaker-remote-1.1.20-5.el7_7.1.x86_64
python-ncclient-0.4.7-5.el7ost.noarch
```
```
(undercloud) [stack@undercloud dc1]$ cat ComputeDpdkHw0-192.168.11.71
192.168.11.5:8787/rhosp13/openstack-nova-compute:13.0-115.1574774353
192.168.11.5:8787/rhosp13/openstack-ceilometer-compute:13.0-93
...
pacemaker-remote-1.1.20-5.el7_7.1.x86_64
python-ncclient-0.4.7-5.el7ost.noarch
```
bash:
```
(undercloud) [stack@undercloud dc1]$ cat ip-nodeflavor.txt
192.168.11.72 ComputeDpdkHw0
192.168.11.71 ComputeDpdkHw0
127.0.0.1 Director
192.168.11.10 Controller
```
```
(undercloud) [stack@undercloud dc1]$ cat dc-diff-report.txt
```
python:
```
(undercloud) [stack@undercloud dc1]$ cat ip-nodeflavor.txt
{'192.168.11.72': 'ComputeDpdkHw0', '192.168.11.71': 'ComputeDpdkHw0', '127.0.0.1': 'Director', '192.168.11.10': 'Controller'}
```
```
(undercloud) [stack@undercloud dc1]$ cat dc-diff-report.txt
***** 192.168.11.72 ComputeDpdkHw0 *****
***** 192.168.11.71 ComputeDpdkHw0 *****
***** 127.0.0.1 Director *****
***** 192.168.11.10 Controller *****
--- file1
+++ file2
@@ -1,2 +1 @@
-192.168.11.5:8787/rhosp13/openstack-neutron-dhcp-agent:13.0-101
 192.168.11.5:8787/rhosp13/openstack-neutron-dhcp-agent:13.0-101
```

#Script to compare OpenStack nodes per type
#a. Check the variables to make sure they match the environment
#b. Run the script from Undercloud/Director as stack user

#Modules
#For SSH access
import base64, paramiko ,sys 
#To get output
import subprocess
#To compare files
import difflib
#To delete file
import os

#Variables
dc_path='/tmp/dc/'
report_file=dc_path+'diff-report.txt'
input_file=dc_path+'ip-nodeflavor.txt'
node_user = 'heat-admin'
getnodeinfo_cmd = "source /home/stack/stackrc && openstack server list | awk '{print $8, $12}' | awk -F= '{print $2}' | awk '!/^$/' "
ssh_command = " rpm -qa | grep -E 'appformix*|ceph*|container*|contrail*|corosync*|docker*|galera*|haproxy*|hiera*|ipa*|kernel*|mariadb*|memcached*|openstack*|openvswitch*|pacemaker*|pcs*|postgresql*|puppet*|python*' & sudo docker ps --format '{{.Image}}' "
#Init dictionnary and node type variables
nodes_datas_dict = {}
#Each type of node needs its OpenStack Flavor
openstack_director='Director'
openstack_controller='Controller'
openstack_compute_0='ComputeDpdkHw0'
openstack_storage_0='CephStorage10Hw5'
contrail_appformix='AppformixController'
contrail_controller='ContrailController'
contrail_analytics_db='ContrailAnalyticsDatabase'
contrail_analytics='ContrailAnalytics'

#Functions
def get_nodes_datas(getnodeinfo_cmd):
  #Delete any existing report file
  os.remove(report_file) if os.path.exists(report_file) else None
  #Get node IP and Flavor datas from OpenStack command output
  ps = subprocess.Popen(getnodeinfo_cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
  for line in iter(ps.stdout.readline,''):
    n_ip, n_type = line.split()
    nodes_datas_dict[n_ip] = n_type
	
def ssh_connection(node_ip, node_user):
  ssh_cnx = paramiko.SSHClient()
  ssh_cnx.set_missing_host_key_policy(paramiko.AutoAddPolicy())
  ssh_cnx.connect(node_ip, username=node_user)
  return ssh_cnx

def get_ssh_datas(ssh_cnx, node_ip, node_flavor, ssh_command):
  #Checking if directory already exists
  try:
    if not os.path.exists(os.path.dirname(dc_path)):
       os.makedirs(os.path.dirname(dc_path))
  except OSError as err:
   print(err)
  #Open node data files and write into them
  datafile = open(dc_path + node_flavor + '-' + node_ip, 'w+')
  stdin_, stdout_, stderr_ = ssh_cnx.exec_command(ssh_command)
  lines = stdout_.readlines()
  for line in lines:
    datafile.write(line)
  datafile.close()

def dict_update_export():
  #Add director node data file (useful when comparing DCs)
  subprocess.Popen('rpm -qa | sort',shell=True,stdout=open(dc_path + 'Director-127.0.0.1','w'))
  nodes_datas_dict['127.0.0.1']='Director'
  #Export dict to a file (useful when comparing DCs)
  backup_dict = open (input_file,'w')
  backup_dict.write( str(nodes_datas_dict) )
  backup_dict.close()

def cmp_nodes(report_file, node_ref, node_ip, node_flavor):
  reportfile = open( report_file, 'a')
  print >> reportfile, ("*****"),node_ip,node_flavor,("*****")
  with open(dc_path + node_flavor + '-' + node_ref, 'r') as file1:
    with open(dc_path + node_flavor + '-' + node_ip, 'r') as file2:
      diff = difflib.unified_diff(file1.readlines(), file2.readlines(), fromfile='file1', tofile='file2',n=1)
      for line in diff:
        reportfile.write(line)
  reportfile.close()

#Calls
def main ():

  print '1.Collect IP and Flavor information from Undercloud'
  get_nodes_datas(getnodeinfo_cmd)

  print '2.Collect datas from each node'
  for nodeip, nodeflavor in nodes_datas_dict.iteritems():
    ssh_cnx_rtrn = ssh_connection (nodeip, node_user)
    get_ssh_datas(ssh_cnx_rtrn, nodeip, nodeflavor, ssh_command)

  print '3.Add Director and export node IP and Flavor datas'
  dict_update_export()

  print '4.Comparing datas between node flavors'
  #Init node reference variable
  openstack_director_ref = openstack_controller_ref = openstack_compute_0_ref = openstack_storage_0_ref = contrail_appformix_ref = contrail_controller_ref = contrail_analytics_db_ref = contrail_analytics_ref = 'init'
  #Case like loop to compare each node per type
  for nodeip, nodeflavor in nodes_datas_dict.iteritems():
    if nodeflavor == openstack_director:
      if openstack_director_ref == 'init':
        openstack_director_ref = nodeip
      cmp_nodes(report_file, openstack_director_ref, nodeip, nodeflavor)
    elif nodeflavor == openstack_controller:
      if openstack_controller_ref == 'init':
        openstack_controller_ref = nodeip
      cmp_nodes(report_file, openstack_controller_ref, nodeip, nodeflavor)
    elif nodeflavor == openstack_compute_0:
      if openstack_compute_0_ref == 'init':
        openstack_compute_0_ref = nodeip
      cmp_nodes(report_file, openstack_compute_0_ref, nodeip, nodeflavor)
    elif nodeflavor == openstack_storage_0:
      if openstack_storage_0_ref == 'init':
        openstack_storage_0_ref = nodeip
      cmp_nodes(report_file, openstack_storage_0_ref, nodeip, nodeflavor)
    elif nodeflavor == contrail_appformix:
      if contrail_appformix_ref == 'init':
        contrail_appformix_ref = nodeip
      cmp_nodes(report_file, contrail_appformix_ref, nodeip, nodeflavor)
    elif nodeflavor == contrail_controller:
      if contrail_controller_ref == 'init':
        contrail_controller_ref = nodeip
      cmp_nodes(report_file, contrail_controller_ref, nodeip, nodeflavor)
    elif nodeflavor == contrail_analytics_db:
      if contrail_analytics_db_ref == 'init':
        contrail_analytics_db_ref = nodeip
      cmp_nodes(report_file, contrail_analytics_db_ref, nodeip, nodeflavor)
    elif nodeflavor == contrail_analytics:
      if contrail_analytics_ref == 'init':
        contrail_analytics_ref = nodeip
      cmp_nodes(report_file, contrail_analytics_ref, nodeip, nodeflavor)
    else: 
      print("Node comparison failed, check the node flavors: "), nodeip
  print "Report can be found here:", report_file

if __name__ == "__main__":
    main()

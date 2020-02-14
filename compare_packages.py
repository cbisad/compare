#Script to compare OpenStack packages as well as Docker container versions
#Needs to be run from Undercloud

#Modules
#For SSH access
import base64
import paramiko
import sys
#To get output
import subprocess
#To compare files
import difflib
#To delete file
import os

#Variables
node_user = 'heat-admin'
getnodeinfo_cmd = "source /home/stack/stackrc && openstack server list | awk '{print $8, $12}' | awk -F= '{print $2}' | awk '!/^$/'"
ssh_command = "rpm -qa | grep openstack | sort && sudo docker ps --format '{{.Image}}' | sort "
report_file = "/tmp/report_file.txt"
#Init dictionnary and node type variables
nodes_datas_dict = {}

#Functions
def get_nodes_datas(getnodeinfo_cmd):
  ps = subprocess.Popen(getnodeinfo_cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
  for line in iter(ps.stdout.readline,''):
    n_ip, n_type = line.split()
    nodes_datas_dict[n_ip] = n_type

def ssh_connection(node_ip, node_user):
  ssh_cnx = paramiko.SSHClient()
  ssh_cnx.set_missing_host_key_policy(paramiko.AutoAddPolicy())
  ssh_cnx.connect(node_ip, username=node_user)
  return ssh_cnx

def get_ssh_datas(ssh_cnx, node_ip, node_role, ssh_command):
  datafile = open('/tmp/' + node_role + '-' + node_ip, 'w+')
  stdin_, stdout_, stderr_ = ssh_cnx.exec_command(ssh_command)
  lines = stdout_.readlines()
  for line in lines:
    datafile.write(line)
  datafile.close()

def cmp_nodes(report_file, node_ref, node_ip, node_role):
  reportfile = open( report_file, 'a')
  print >> reportfile, ("*****"),node_ip,node_role,("*****")
  with open('/tmp/' + node_role + '-' + node_ref, 'r') as file1:
    with open('/tmp/' + node_role + '-' + node_ip, 'r') as file2:
      diff = difflib.unified_diff(file1.readlines(), file2.readlines(), fromfile='file1', tofile='file2',)
      for line in diff:
        reportfile.write(line)
  reportfile.close()

#Calls
def main ():
  #Get node datas from Undercloud
  get_nodes_datas(getnodeinfo_cmd)
  #SSH connect to each node and collect data from "ssh_command"
  for nodeip, noderole in nodes_datas_dict.iteritems():
    ssh_cnx_rtrn = ssh_connection (nodeip, node_user)
    get_ssh_datas(ssh_cnx_rtrn, nodeip, noderole, ssh_command)
  #Delete any existing report file
  os.remove(report_file) if os.path.exists(report_file) else None
  #Case like loop to compare each node per type
  #Init node reference variable
  node_Controller_ref = node_ComputeDpdkHw0_ref = node_CephStorageHw10_ref = node_AppformixController_ref = node_ContrailController_ref = node_ContrailAnalyticsDatabase_ref = node_ContrailAnalytics_ref = 'init'
  for nodeip, noderole in nodes_datas_dict.iteritems():
    if noderole == "Controller":
      if node_Controller_ref == 'init':
        node_Controller_ref = nodeip
      cmp_nodes(report_file, node_Controller_ref, nodeip, noderole)
    elif noderole == "ComputeDpdkHw0":
      if node_ComputeDpdkHw0_ref == 'init':
        node_ComputeDpdkHw0_ref = nodeip
      cmp_nodes(report_file, node_ComputeDpdkHw0_ref, nodeip, noderole)
    elif noderole == "CephStorageHw10":
      if node_CephStorageHw10_ref == 'init':
        node_CephStorageHw10_ref = nodeip
      cmp_nodes(report_file, node_CephStorageHw10_ref, nodeip, noderole)
    elif noderole == "AppformixController":
      if node_AppformixController_ref == 'init':
        node_AppformixController_ref = nodeip
      cmp_nodes(report_file, node_AppformixController_ref, nodeip, noderole)
    elif noderole == "ContrailController":
      if node_ContrailController_ref == 'init':
        node_ContrailController_ref = nodeip
      cmp_nodes(report_file, node_ContrailController_ref, nodeip, noderole)
    elif noderole == "ContrailAnalyticsDatabase":
      if node_ContrailAnalyticsDatabase_ref == 'init':
        node_ContrailAnalyticsDatabase_ref = nodeip
      cmp_nodes(report_file, node_ContrailAnalyticsDatabase_ref, nodeip, noderole)
    elif noderole == "ContrailAnalytics":
      if node_ContrailAnalytics_ref == 'init':
        node_ContrailAnalytics_ref = nodeip
      cmp_nodes(report_file, node_ContrailAnalytics_ref, nodeip, noderole)
    else: 
      print("Incorrect Role")
  print "Report file available in:", report_file

if __name__ == "__main__":
    main()

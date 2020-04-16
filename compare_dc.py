#Script to compare 2 directories from where the local comparisons between nodes within a DC have been done already
#a. As each DC does not have IP connectivity to the other, it is needed to run this script either locally or on a tool server 
#b. Create an archives of the files: tar cvf compare_packages.tgz diff-report.txt diff-report.txt ip-NodeFlavor.txt *C[o,e]*
#c. scp the files: scp compare_packages.tgz <remote_server>:/tmp
#d. Check the variables to make sure they match the environment

#Modules
#To get output
import subprocess
#To compare files
import difflib
#To delete file
import os

#Variables
dc1_path='/tmp/dc1/'
dc2_path='/tmp/dc2/'
dc1_input_file=dc1_path+'ip-nodeflavor.txt'
dc2_input_file=dc2_path+'ip-nodeflavor.txt'
dc1_report_file=dc1_path+'dc-diff-report.txt'
#Each type of node needs its OpenStack Flavor
openstack_director='Director'
openstack_controller='Controller'
openstack_compute_0='ComputeDpdkHw0'
openstack_storage_0='CephStorage10Hw5'
contrail_appformix='AppformixController'
contrail_controller='ContrailController'
contrail_analytics_db='ContrailAnalyticsDatabase'
contrail_analytics='ContrailAnalytics'
#Init node reference variable
class Node_ref:
  openstack_director_ref = openstack_controller_ref = openstack_compute_0_ref = openstack_storage_0_ref = contrail_appformix_ref = contrail_controller_ref = contrail_analytics_db_ref = contrail_analytics_ref = 'init'

#Functions
def cmp_nodes(dc1_report_file, node_ref, node_ip, node_flavor):
  reportfile = open( dc1_report_file, 'a')
  print >> reportfile, ("*****"),node_ip,node_flavor,("*****")
  with open(dc2_path + node_flavor + '-' + node_ref, 'r') as file1:
    with open(dc1_path + node_flavor + '-' + node_ip, 'r') as file2:
      diff = difflib.unified_diff(file1.readlines(), file2.readlines(), fromfile='file1', tofile='file2',n=1)
      for line in diff:
        reportfile.write(line)
  reportfile.close()

#Calls
def main ():

  #Delete any existing report file
  os.remove(dc1_report_file) if os.path.exists(dc1_report_file) else None
  #Node reference class instance
  os_node_ref = Node_ref()

  print '1.Create reference nodes from DC2'
  #Case to Check if the variable has been used already, if not, it will initilize it with the first node IP within the Flavor using dc2 nodes
  dc2_nodes_datas_dict = eval(open(dc2_input_file).read())
  for nodeip, nodeflavor in dc2_nodes_datas_dict.iteritems():
    if nodeflavor == openstack_director:
      if os_node_ref.openstack_director_ref == 'init':
        os_node_ref.openstack_director_ref = nodeip
    elif nodeflavor == openstack_controller:
      if os_node_ref.openstack_controller_ref == 'init':
        os_node_ref.openstack_controller_ref = nodeip
    elif nodeflavor == openstack_compute_0:
      if os_node_ref.openstack_compute_0_ref == 'init':
        os_node_ref.openstack_compute_0_ref = nodeip
    elif nodeflavor == openstack_storage_0:
      if os_node_ref.openstack_storage_0_ref == 'init':
        os_node_ref.openstack_storage_0_ref = nodeip
    elif nodeflavor == contrail_appformix:
      if os_node_ref.contrail_appformix_ref == 'init':
        os_node_ref.contrail_appformix_ref = nodeip
    elif nodeflavor == contrail_controller:
      if os_node_ref.contrail_controller_ref == 'init':
        os_node_ref.contrail_controller_ref = nodeip
    elif nodeflavor == contrail_analytics_db:
      if os_node_ref.contrail_analytics_db_ref == 'init':
        os_node_ref.contrail_analytics_db_ref = nodeip
    elif nodeflavor == contrail_analytics:
      if os_node_ref.contrail_analytics_ref == 'init':
        os_node_ref.contrail_analytics_ref = nodeip
    else: 
      print("Node reference creation failed, check the node flavors"), nodeip

  print '2.Compare nodes between DC1 and DC2 reference nodes'
  dc1_nodes_datas_dict = eval(open(dc1_input_file).read())
  for nodeip, nodeflavor in dc1_nodes_datas_dict.iteritems():
    if nodeflavor == openstack_director:
      cmp_nodes(dc1_report_file, os_node_ref.openstack_director_ref, nodeip, nodeflavor)
    elif nodeflavor == openstack_controller:
      cmp_nodes(dc1_report_file, os_node_ref.openstack_controller_ref, nodeip, nodeflavor)
    elif nodeflavor == openstack_compute_0:
      cmp_nodes(dc1_report_file, os_node_ref.openstack_compute_0_ref, nodeip, nodeflavor)
    elif nodeflavor == openstack_storage_0:
      cmp_nodes(dc1_report_file, os_node_ref.openstack_storage_0_ref, nodeip, nodeflavor)
    elif nodeflavor == contrail_appformix:
      cmp_nodes(dc1_report_file, os_node_ref.contrail_appformix_ref, nodeip, nodeflavor)
    elif nodeflavor == contrail_controller:
      cmp_nodes(dc1_report_file, os_node_ref.contrail_controller_ref, nodeip, nodeflavor)
    elif nodeflavor == contrail_analytics_db:
      cmp_nodes(dc1_report_file, os_node_ref.contrail_analytics_db_ref, nodeip, nodeflavor)
    elif nodeflavor == contrail_analytics:
      cmp_nodes(dc1_report_file, os_node_ref.contrail_analytics_ref, nodeip, nodeflavor)
    else: 
      print("Node comparison failed, check the node flavors"), nodeip
  print 'Report can be found here:', dc1_report_file

if __name__ == "__main__":
    main()

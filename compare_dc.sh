#Script to compare 2 directories from where the local comparisons between nodes within a DC have been done already
#a. As each DC does not have IP connectivity to the other, it is needed to run this script either locally or on a tool server 
#b. Create an archives of the files: tar cvf compare_packages.tgz diff-report.txt diff-report.txt ip-NodeFlavor.txt *C[o,e]*
#c. scp the files: scp compare_packages.tgz <remote_server>:/tmp
#d. Check the variables to make sure they match the environment

###Variables
dc1_path='/tmp/dc1/'
dc2_path='/tmp/dc2/'
dc1_input_file=${dc1_path}ip-nodeflavor.txt
dc2_input_file=${dc2_path}ip-nodeflavor.txt
dc1_report_file=${dc1_path}dc-diff-report.txt

#Each type of node needs an array to store its IP and Flavor
arrays="IP_NodeFlavor_Array Director_IP_array Controller_IP_array Compute_0_IP_array CephStorage_0_IP_array AppformixController_IP_array ContrailController_IP_array ContrailAnalyticsDatabase_IP_array ContrailAnalytics_IP_array"

#Each type of node needs its OpenStack Flavor
openstack_director=Director
openstack_controller=Controller
openstack_compute_0=ComputeDpdkHw0
openstack_storage_0=CephStorage10Hw5
contrail_appformix=AppformixController
contrail_controller=ContrailController
contrail_analytics_db=ContrailAnalyticsDatabase
contrail_analytics=ContrailAnalytics

###Arrays declaration and init
for array in $arrays; do declare $array; eval "$array=( init )"; done

###Reset data files
cat /dev/null > $dc1_report_file


###1.Create reference nodes from DC2
echo '1.Create reference nodes from DC2:'
while read file_line; 
do IP_NodeFlavor_Array=($file_line); declare IP_NodeFlavor_Array;
        # case 
        case ${IP_NodeFlavor_Array[1]} in
                "$openstack_director")
                              # Check if the variable has been used already, if not, will initilize it with the first node IP within the Flavor
                              if [ ${Director_IP_array[0]} = "init" ]; then
                                Director_IP_array=${IP_NodeFlavor_Array[0]}; fi ;;
                "$openstack_controller") 
                              if [ ${Controller_IP_array[0]} = "init" ]; then
                                Controller_IP_array=${IP_NodeFlavor_Array[0]}; fi ;;
                "$openstack_compute_0")
                              if [ ${Compute_0_IP_array[0]} = "init" ]; then
                                Compute_0_IP_array=${IP_NodeFlavor_Array[0]}; fi ;;
                "$openstack_storage_0")
                              if [ ${CephStorage_0_IP_array[0]} = "init" ]; then
                                CephStorage_0_IP_array=${IP_NodeFlavor_Array[0]}; fi ;;
                "$contrail_appformix")
                              if [ ${AppformixController_IP_array[0]} = "init" ]; then
                                AppformixController_IP_array=${IP_NodeFlavor_Array[0]}; fi ;;
                "$contrail_controller")
                              if [ ${ContrailController_IP_array[0]} = "init" ]; then
                                ContrailController_IP_array=${IP_NodeFlavor_Array[0]}; fi ;;
                "$contrail_analytics_db")
                              if [ ${ContrailAnalyticsDatabase_IP_array[0]} = "init" ]; then
                                ContrailAnalyticsDatabase_IP_array=${IP_NodeFlavor_Array[0]}; fi ;;
                "$contrail_analytics")
                              if [ ${ContrailAnalytics_IP_array[0]} = "init" ]; then
                                ContrailAnalytics_IP_array=${IP_NodeFlavor_Array[0]}; fi ;;
                *) echo "Node reference creation failed, check the node flavors"
                   exit 1 ;;
        esac
done < $dc2_input_file


###2.Loop going through the list of IPs/NodeFlavor and comparing the NodeFlavor-IP files from DC1 to DC2 reference node
echo '2.Compare nodes between DC1 and DC2:'
while read file_line; 
do IP_NodeFlavor_Array=($file_line); declare IP_NodeFlavor_Array;
echo '*****' Node: ${IP_NodeFlavor_Array[0]} ${IP_NodeFlavor_Array[1]} '*****' >> $dc1_report_file
        # case to split node per type and compare datas with the first node of the list only
        case ${IP_NodeFlavor_Array[1]} in
                "$openstack_director")
                              diff $dc2_path${IP_NodeFlavor_Array[1]}-${Director_IP_array[0]} $dc1_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $dc1_report_file ;;
                "$openstack_controller") 
                              diff $dc2_path${IP_NodeFlavor_Array[1]}-${Controller_IP_array[0]} $dc1_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $dc1_report_file ;;
                "$openstack_compute_0")
                              diff $dc2_path${IP_NodeFlavor_Array[1]}-${Compute_0_IP_array[0]} $dc1_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $dc1_report_file ;;
                "$openstack_storage_0")
                              diff $dc2_path${IP_NodeFlavor_Array[1]}-${CephStorage_0_IP_array[0]} $dc1_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $dc1_report_file ;;
                "$contrail_appformix")
                              diff $dc2_path${IP_NodeFlavor_Array[1]}-${AppformixController_IP_array[0]} $dc1_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $dc1_report_file ;;
                "$contrail_controller")
                              diff $dc2_path${IP_NodeFlavor_Array[1]}-${ContrailController_IP_array[0]} $dc1_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $dc1_report_file ;;
                "$contrail_analytics_db")
                              diff $dc2_path${IP_NodeFlavor_Array[1]}-${ContrailAnalyticsDatabase_IP_array[0]} $dc1_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $dc1_report_file ;;
                "$contrail_analytics")
                              diff $dc2_path${IP_NodeFlavor_Array[1]}-${ContrailAnalytics_IP_array[0]} $dc1_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $dc1_report_file ;;
                *) echo "Compare DCs failed, check the node flavors"
                   exit 1 ;;
        esac
done < $dc1_input_file
echo "Report can be found here:" $dc1_report_file

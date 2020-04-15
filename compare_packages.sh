#Script to compare OpenStack nodes per type
#a. Check the variables to make sure they match the environment
#b. Run the script from Undercloud/Director as stack user

#Variables
dc_path='/tmp/dc/'
input_file=${dc_path}ip-nodeflavor.txt
report_file=${dc_path}diff-report.txt
buffer_file=${dc_path}sort_buffer.txt
openstack_stackrc='/home/stack/stackrc'
openstack_user='heat-admin'
ssh_commands=" rpm -qa | grep -E 'appformix*|ceph*|container*|contrail*|corosync*|docker*|galera*|haproxy*|hiera*|ipa*|kernel*|mariadb*|memcached*|openstack*|openvswitch*|pacemaker*|pcs*|postgresql*|puppet*|python*' & sudo docker ps --format '{{.Image}}' "

#Each type of node needs an array to store its IP and Flavor
arrays="IP_NodeFlavor_Array Director_IP_array Controller_IP_array Compute_0_IP_array CephStorage_0_IP_array AppformixController_IP_array ContrailController_IP_array ContrailAnalyticsDatabase_IP_array ContrailAnalytics_IP_array"

#Each type of node needs its OpenStack Flavor
openstack_director=Director
openstack_controller=baremetal
openstack_compute_0=baremetal-extra
openstack_storage_0=CephStorage10Hw5
contrail_appformix=AppformixController
contrail_controller=ContrailController
contrail_analytics_db=ContrailAnalyticsDatabase
contrail_analytics=ContrailAnalytics

###Arrays declaration and init
for array in $arrays; do declare $array; eval "$array=( init )"; done

#Reset data files
cat /dev/null > $report_file
cat /dev/null > $input_file


#1.Collect IP and Flavor information from Undercloud and sort nodes per flavor
echo '1.Collect IP and Flavor information from Undercloud'
mkdir -p $dc_path
source $openstack_stackrc
openstack server list | awk '{print $8, $12}' | awk -F= '{print $2}' | awk '!/^$/' >> $input_file
sort -k2 $input_file > $buffer_file; cp $buffer_file $input_file


#2.SSH to each node, collect datas, copy them locally in <Flavor>-<IP> filename and sort the datas to make the comparison output easier to read
echo '2.Collect datas from each node'
while read file_line; 
do IP_NodeFlavor_Array=($file_line);
ssh -l $openstack_user ${IP_NodeFlavor_Array[0]} $ssh_commands > $dc_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} < /dev/null; 
sort $dc_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} > $buffer_file; cp $buffer_file $dc_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]};
done < $input_file
#Add director (useful when comparing DCs)
rpm -qa | sort > ${dc_path}Director-127.0.0.1 && echo "127.0.0.1 Director" >> $input_file


#3.Loop going through the list of IPs/Flavor and comparing the <Flavor>-<IP> files
echo '3.Comparing datas between node flavors'
while read file_line; 
do IP_NodeFlavor_Array=($file_line); declare IP_NodeFlavor_Array;
echo '*****' Node: ${IP_NodeFlavor_Array[0]} ${IP_NodeFlavor_Array[1]} '*****' >> $report_file
        # case to split node per flavor and compare datas with the first node of the list only (reference node)
        case ${IP_NodeFlavor_Array[1]} in
                "$openstack_director")
                              # Check if the variable has been used already, if not, will initilize it with the first node IP of the list to compare against other nodes with the same flavor
                              if [ ${Director_IP_array[0]} = "init" ]; then
                                Director_IP_array=${IP_NodeFlavor_Array[0]}; fi
                              diff $dc_path${IP_NodeFlavor_Array[1]}-${Director_IP_array[0]} $dc_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $report_file ;;
                "$openstack_controller") 
                              # Check if the variable has been used already, if not, will initilize it with the first node IP of the list to compare against other nodes with the same flavor
                              if [ ${Controller_IP_array[0]} = "init" ]; then
                                Controller_IP_array=${IP_NodeFlavor_Array[0]}; fi
                              diff $dc_path${IP_NodeFlavor_Array[1]}-${Controller_IP_array[0]} $dc_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $report_file ;;
                "$openstack_compute_0")
                              if [ ${Compute_0_IP_array[0]} = "init" ]; then
                                Compute_0_IP_array=${IP_NodeFlavor_Array[0]}; fi
                              diff $dc_path${IP_NodeFlavor_Array[1]}-${Compute_0_IP_array[0]} $dc_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $report_file ;;
                "$openstack_storage_0")
                              if [ ${CephStorage_0_IP_array[0]} = "init" ]; then
                                CephStorage_0_IP_array=${IP_NodeFlavor_Array[0]}; fi
                              diff $dc_path${IP_NodeFlavor_Array[1]}-${CephStorage_0_IP_array[0]} $dc_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $report_file ;;
                "$contrail_appformix")
                              if [ ${AppformixController_IP_array[0]} = "init" ]; then
                                AppformixController_IP_array=${IP_NodeFlavor_Array[0]}; fi
                              diff $dc_path${IP_NodeFlavor_Array[1]}-${AppformixController_IP_array[0]} $dc_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $report_file ;;
                "$contrail_controller")
                              if [ ${ContrailController_IP_array[0]} = "init" ]; then
                                ContrailController_IP_array=${IP_NodeFlavor_Array[0]}; fi
                              diff $dc_path${IP_NodeFlavor_Array[1]}-${ContrailController_IP_array[0]} $dc_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $report_file ;;
                "$contrail_analytics_db")
                              if [ ${ContrailAnalyticsDatabase_IP_array[0]} = "init" ]; then
                                ContrailAnalyticsDatabase_IP_array=${IP_NodeFlavor_Array[0]}; fi
                              diff $dc_path${IP_NodeFlavor_Array[1]}-${ContrailAnalyticsDatabase_IP_array[0]} $dc_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $report_file ;;
                "$contrail_analytics")
                              if [ ${ContrailAnalytics_IP_array[0]} = "init" ]; then
                                ContrailAnalytics_IP_array=${IP_NodeFlavor_Array[0]}; fi
                              diff $dc_path${IP_NodeFlavor_Array[1]}-${ContrailAnalytics_IP_array[0]} $dc_path${IP_NodeFlavor_Array[1]}-${IP_NodeFlavor_Array[0]} >> $report_file ;;
                *) echo "Node comparison failed, check the node flavors: " ${IP_NodeFlavor_Array[0]}
                   exit 1 ;;
        esac
done < $input_file
echo "Report can be found here:" $report_file
